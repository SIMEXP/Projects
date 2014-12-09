function mpart = niak_part2mpart( part , flag_lvec )
% Convert a partition on nodes into a partition on edges.
% 
% MPART = NIAK_PART2MPART( PART , FLAG_LVEC )
%
% PART (array Kx1) a partition of the K nodes
% FLAG_LVEC (default true) if the flag is on, use NIAK_MAT2LVEC to vectorize the mask. 
%   Otherwise, use NIAK_MAT2VEC.
% MPART (vector 1xL) a partition of the L vectorized edges into within or between partition-coefficients.
%   The edges are vectorized with NIAK_MAT2(LVEC/VEC).
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
        mpart(part==k2,part==k1) = nb_el;
    end
end

%% Vectorize the matrix partition
if (nargin<2)||flag_lvec
    mpart = niak_mat2lvec(mpart);
else 
    mpart = niak_mat2vec(mpart);
end