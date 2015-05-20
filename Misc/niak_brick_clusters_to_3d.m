function [files_in,files_out,opt] = niak_brick_clusters_to_3d(files_in,files_out,opt)
% Extract a collection of binary maps from a single volume with multiple clusters
%
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_CLUSTERS_TO_3D(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS
%
% FILES_IN  
%   (string) a 3D dataset VOL with multiple clusters coded by integer 
%   values : cluster I is (VOL==I)
%
% FILES_OUT 
%   (cell of strings, default <BASE NAME INPUT>_<NUM CLUST>.<EXT>)
%       Each entry is the file name for a 3D volume CLUSTI, equals to 
%       I in (VOL==I) (see OPT.FLAG_LABEL below).
%
% OPT   
%   (structure) with the following fields :
%
%   FLAG_LABEL
%       (boolean, default true) if FLAG_LABEL is true, cluster I is 
%       filled with Is, otherwise only with 1s.
%
%   FOLDER_OUT 
%       (string, default: path of FILES_IN) If present,
%       all default outputs will be created in the folder FOLDER_OUT.
%       The folder needs to be created beforehand.
%
%   FLAG_TEST 
%       (boolean, default 0) if FLAG_TEST equals 1, the brick does not 
%       do anything but update the default values in FILES_IN, FILES_OUT 
%       and OPT.
%
% _________________________________________________________________________
% OUTPUTS
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%
% _________________________________________________________________________
% EXAMPLE:
%
% how to generate multiple files of individual clusters from one volume
% with multiple clusters, both inputs and outputs in the current folder:
%
%   files_in = 'my_clusters.nii.gz';
%   niak_brick_clusters_to_3d(files_in)
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center,
% Montreal Neurological Institute, McGill University, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : pipeline, niak, preprocessing, fMRI

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('files_in','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_4D_TO_3D(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_3d_to_4d'' for more info.')
end

if ~exist('files_out','var')
    files_out = '';
end

%% Options
list_fields    = {'flag_label' , 'flag_test' , 'folder_out' };
list_defaults  = {true         , 0           , ''           };
if nargin < 3
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
else
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

[path_f,name_f,ext_f] = niak_fileparts(files_in);

if isempty(opt.folder_out)
    opt.folder_out = path_f;
end

if opt.flag_test == 1
    return
end

[hdr,vol] = niak_read_vol(files_in);
vol = double(round(vol));
nb_clust = max(vol(:));

%% Files out
if isempty(files_out)
    files_out = cell([nb_clust 1]);
    for num_k = 1:nb_clust
        lab_vol = [repmat('0',[1 4-length(num2str(num_k))]) num2str(num_k)];
        files_out{num_k} = cat(2,opt.folder_out,name_f,'_',lab_vol,ext_f);        
    end    
end        
%%%%%%%%%%%%%%%%%%%%%%%%
%% Extracting volumes %%
%%%%%%%%%%%%%%%%%%%%%%%%
for num_k = 1:nb_clust
    hdr.file_name = files_out{num_k};
    mask_tmp = zeros(size(vol));
    if opt.flag_label
        mask_tmp(vol==num_k) = num_k;
    else
        mask_tmp(vol==num_k) = 1;
    end
    niak_write_vol(hdr,mask_tmp);
end
