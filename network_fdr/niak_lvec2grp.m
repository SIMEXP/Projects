function [grp,ind,vmpart] = niak_lvec2grp( lvec , part )
% Convert an array of vectorized matrices, along with a partition, into a cell of array
% 
% [GRP,IND,VMPART] = NIAK_LVEC2GRP( LVEC , PART )
%
% LVEC (array NxL) where each row is a vectorized matrix of square size KxK (using either NIAK_LVEC2MAT or NIAK_VEC2MAT).
% PART (array Kx1) a partition of the K units
% GRP (cell of array) GRP{i} is a N x Li array, including all the values of the matrices associated with the IND(i,1)-th 
%   element of the partition, and the IND(i,2)-th element of the partition. The columns of GRP{i} correspond to 
%   the columns of LVEC indexed by (VMPART==i).
% IND (array Ix2) each row of IND is a distinct pair of elements in the partition (with smallest index first, only 
%   the pair (k,k') with k<=k' is listed.
% VMPART (vector) a partition of the L vectorized matrix elements into within or between partition-coefficients.
%
% Note that if LVEC is a single vectorized matrix (i.e. N==1), LVEC can be passed as either a row or column vector.
%
% Copyright (c) Pierre Bellec, 
% Centre de recherche de l'institut de gériatrie de Montréal, 
% Department of Computer Science and Operations Research
% University of Montreal, Québec, Canada, 2014
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.

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

%% Special case: a single vectorized matrix

%% Check the format of the partition
if (size(part,1)>1)&&(size(part,2)>1)
    error('PART should be a vector')
end
n = length(part);
nb_part = max(part(:));
if any(~ismember(unique(part),1:nb_part))||(any(~ismember(1:nb_part,unique(part))))
    error('Elements in the partition need to be numbered from 1 to an integer K>1')
end

%% Build a matrix partition
nb_el = 0;
mpart = zeros(n,n);
for k1 = 1:nb_part
    for k2 = k1:nb_part
        nb_el = nb_el+1;
        ind(nb_el,1) = k1;
        ind(nb_el,2) = k2;
        mpart(part==k1,part==k2) = nb_el;
    end
end

%% Vectorize the matrix partition
vmpart = niak_mat2lvec(mpart);
if length(vmpart)~=size(lvec,2)
    vmpart = niak_mat2vec(part);
end
if length(vmpart)~=size(lvec,2)
    error('The size of the partition does not correspond to the number of columns in LVEC')
end

%% Now generate the group
grp = cell(nb_el,1);
for ee = 1:nb_el
    grp{ee} = lvec(:,vmpart==ee);
end