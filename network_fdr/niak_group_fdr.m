function [test,fdr] = niak_group_fdr(pce,pi_g_0,mpart,q)
% Estimate the false-discovery rate in multiple group of tests 
%
% [TEST,FDR] = NIAK_FDR( PCE , PI_0 , MPART , [Q] )
%
% PCE (vector Nx1) PCE(i) is the per-comparison error of the ith test (aka the uncorrected p-value).
% PI_0 (vector Kx1) PI_0(k) is the estimated proportion of null hypothesis in the k-th group.
% MPART (vector Nx1) a partition of the tests. MPART(i) is the number of the cluster of test i. 
%   Clusters need to be numbered from 1 to K, without empty clusters.
% Q (scalar, default 0.05) the threshold on an acceptable level of false-discovery rate.
%
% TEST (array) TEST(i,j) is 1 if FDR(i,j)<=Q, and 0 otherwise.
% FDR (array) FDR(i,j) is the false-discovery rate associated with a threshold of 
%   PCE(i) after weighting each group by the proportion of true null.
% 
% REFERENCE:
%
%   Hu, J. X., Zhao, H., Zhou, H. H. (2010), "False discovery rate control 
%   with groups". Journal of the American Statistical Association 105 (491), 
%   1215-1227. URL http://dx.doi.org/10.1198/jasa.2010.tm09329
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2014.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : group false-discovery rate

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

if nargin < 4
    q = 0.05;
end
n = length(pce);
m = max(mpart);

% Generate the re-weightening of the p-values based on the estimated number of discoveries
pi_g_1 = 1-pi_g_0; % the proportion of true non-null
pi_0 = mean(pi_g_0); % The global proportion of true non-null
w = zeros(m,1);
w(pi_g_0~=1) = (1-pi_0) * pi_g_0(pi_g_0~=1)./pi_g_1(pi_g_0~=1);   
w(pi_g_0==1) = Inf;    

% Apply for the weight 
for num_part = 1:m
    pce(mpart==num_part) = pce(mpart==num_part)*w(num_part);
end

% run a standard (global) BH procedure, with weighted p-values and modified FDR threshold
if pi_0 == 1
    fdr = ones(size(pce));
    test = zeros(size(pce));
else
    [fdr,test] = niak_fdr(pce(:),'BH',q);
end