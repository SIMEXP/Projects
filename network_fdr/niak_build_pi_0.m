function [pi_0,vol_disc] = niak_build_pi_0(pce_mat,part,method,q,ttest_mat)
% Estimate the proportion of null hypothesis pi_0 in a connectome
%
% PI_0 = NIAK_BUILD_PI_0( PCE , PART , [METHOD] , [Q] , [TTEST] )
%
% PCE (array NxL) each row is a vectorized matrix of per-comparison errors (aka uncorrected p-values)
%    of square size MxM (using either NIAK_LVEC2MAT or NIAK_VEC2MAT).
% PART (vector Mx1) a partition of the units. PART(i) is the number of the partition
%   for unit i. Units have to be numbered from 1 to K (arbitrary K<=N).
% METHOD (string, default 'LSL') the estimator of pi_0
%   'TST' : The two-stage estimator.
%   'LSL' : The least-slope estimator.
% Q (scalar, default 0.05) the FDR level for TST.
% TTEST (array NxL, optional) each row is a vectorized matrix of t-tests
% PI_0 (vector N x K(K+1)/2) PI_0(n,:) is a vectorized version of a KxK matrix where the (k,l) 
%   entry is the estimated proportion of null hypothesis in the tests corresponding to 
%   connections between units in partition k and units in partition l. The vectorization 
%   is achieved using NIAK_MAT2LVEC.
% VOL_DISC (vector N x K(K+1)/2) VOL_DISC(n,:) is a vectorized version of a KxK matrix where
%   the (k,l) entry is the estimated volume of discovery, defined as the max squared t-test
%   if the estimated proportion of null hypothesis is 1, and the sum of the significant
%   squared t-test otherwise. This output can be genereated only is TTEST is present.
%
% REFERENCES:
%
% On the least-slope estimator of the number of discoveries:
%
%   Benjamini, Y., Hochberg, Y., (2000), “On the Adaptive Control of the 
%   False Discovery Rate in Multiple Testing with Independent Statistics,” 
%   Journal of Educational and Behavioral Statistics, 25, 60-83.
% 
% On the two-stage estimator of the number of discoveries:
%
%   Benjamini, Y., Krieger, M. A., and Yekutieli, D. (2006), “Adaptive Linear 
%   Step-up Pocedures That Control the False Discovery Rate,” 
%   Biometrika, 93, 3, 491-507.
%
% SEE ALSO:
% NIAK_LVEC2GRP
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2014.
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

% defaults
if nargin < 3
    method = 'LSL';
end

if nargin < 4
    q = 0.05;
end

if (nargin < 5)&&(nargout>1)
    error('Please specify TTEST to generate VOL_DISC')
end

% Reformat the p-values based on the intra/inter network partition
grp = niak_lvec2grp(pce_mat,part);
if nargin > 4
    grpt = niak_lvec2grp(ttest_mat,part);
end

% Loop over groups
pi_0 = zeros(size(pce_mat,1),length(grp));
if nargout>1
    vol_disc = zeros(size(pce_mat,1),length(grp));
end
for gg = 1:length(grp)
    pce = grp{gg}';
    if nargout>1
        ttest = grpt{gg}';
    end
    n = size(pce,1);
    m = size(pce,2);
    % estimate the number of discoveries

    switch method
        case 'TST'
            % The two-stage method: family-wise BH procedure
            q = q/(1+q);
            [fdr_bh,test_bh] = niak_fdr(pce,'BH',q);
            pi_0(:,gg) = (n-sum(test_bh,1))'/n;
            if nargout>1
                mask_1 = pi_0(:,gg)==1;
                vol_disc(mask_1,gg) = max(ttest(:,mask_1).^2,[],1);
                ttest = ttest.*test_bh;
                vol_disc(~mask_1,gg) = sum(ttest(:,~mask_1).^2,1);
            end
        case 'LSL'

            if nargout > 1
                error('volume of discovery not implemented for the LSL method')
            end
            % The least-slope method
            [val,order] = sort(pce,1,'ascend');            
            l = repmat((n+1-(1:n)'),[1 m]);
            l(val~=1) = l(val~=1)./(1-val(val~=1));
            l(val==1) = Inf;          
            dl = l(2:end,:) - l(1:(end-1),:);            
            pi_0(:,gg) = zeros(m,1);
            for num_c = 1:m               
                ind_c = find(dl(:,num_c)>0,1);
                if isempty(ind_c)
                    ind_c = n-1;
                end
                pi_0(num_c,gg) = min((floor(l(ind_c+1,num_c))+1)/n,1);
            end            
    end
end
