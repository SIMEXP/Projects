function sub = niak_build_subtypes(data,nb_subtype,mask,flag_demean)
% Extract subtypes from functional maps
%
% Syntax: SUB = NIAK_BUILD_SUBTYPES(DATA,NB_SUBTYPE,MASK)
%
% DATA (array nb of subjects x nb of voxels) each row is a connectivity map for one subject.
% NB_SUBTYPE (integer) the number of subtypes.
% MASK (vector  1 x nb of voxels) a binary mask of voxels of interest. Only these voxels will 
%    be used for subtyping, although maps will be generated full brain. By default all voxels 
%    will be used. 
% FLAG_DEMEAN (boolean, default true) Apply demeaning using the global average prior to subtyping. 
% SUB (structure) each field is an output: 
%     R (matrix) inter-suject correlation. 
%     ORDER (vector) an ordering of subjects)
%     HIER (array) a hierarchical clustering on subjects. 
%     PART (array 1 x #subjects) the partition of subjects into subgroups. 
%     MAP (array #subtypes x #voxels) each row is the average map of subtype (de-meaned is FLAG_DEMEAN is true).
%     WEIGHTS (array #subjects x #subtypes) each column is the list of subtype weights for all subject and a particular subtype. 
%
% (C) Pierre Bellec, UNF, CRIUGM, DIRO, University of Montreal, 2016.
% MIT license, see details in the code. 

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% reorganize and normalize data
nb_subject = size(data,1);
nb_voxels = size(data,2);

%% Default mask
if nargin < 3 
    mask = true(1,nb_voxels);
end

%% Default demeaning
if nargin < 4 
    flag_demean = true;
end

% normalize each map to zero mean and unit variance
%data = niak_normalize_tseries(data')'; 
if flag_demean 
    data = niak_normalize_tseries(data,struct('type','mean'));
end

% Perfom a cluster analysis to identify subgroups
% Inter  subject correlation
sub.R = niak_build_correlation(data(:,mask)'); % Compute inter-subject correlation matrix restricted to the mask
% hierarchical clustering
sub.hier = niak_hierarchical_clustering(sub.R);
% build an ordering on the subjects based on the hierarchy
sub.order = niak_hier2order(sub.hier);
% Build subgroups by thresholding the hierarchy
sub.part = niak_threshold_hierarchy(sub.hier,struct('thresh',nb_subtype));

%% Compute subtypes and associated weights
sub.map = zeros(nb_subtype,nb_voxels);
sub.weights = zeros(nb_subject,nb_subtype);
for ss = 1:nb_subtype
    sub.map(ss,:) = mean(data(sub.part==ss,:),1);
    for ssub = 1:nb_subject
        sub.weights(ssub,ss) = corr(sub.map(ss,mask),data(ssub,mask));
    end
end