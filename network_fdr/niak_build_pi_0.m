function pi_0 = niak_build_pi_0_conn(pce,part,method,q)
% Estimate the proportion of null hypothesis pi_0 in a connectome
%
% PI_0 = NIAK_BUILD_PI_0( PCE , PART , [METHOD] , [Q] )
%
% PCE (array NxL) each row is a vectorized matrix of per-comparison errors (aka uncorrected p-values)
%    of square size MxM (using either NIAK_LVEC2MAT or NIAK_VEC2MAT).
% PART (vector Mx1) a partition of the units. PART(i) is the number of the partition
%   for unit i. Units have to be numbered from 1 to K (arbitrary K<=N).
% METHOD (string, default 'LSL') the estimator of pi_0
%   'TST' : The two-stage estimator.
%   'LSL' : The least-slope estimator.
% Q (scalar, default 0.05) the FDR level for TST.
% PI_0 (vector N x K(K+1)/2) PI_0(n,:) is a vectorized version of a K matrix where the (k,l) 
%   entry is the estimated proportion of null hypothesis in the tests corresponding to 
%   connections between units in partition k and units in partition l. The vectorization 
%   is achieved using NIAK_MAT2LVEC.
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
% NIAK_BUILD_PI_0, NIAK_LVEC2GRP
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

grp = niak_lvec2grp(pce,part);
if nargin < 3
    pi_0 = niak_build_pi_0(grp);
elseif nargin==4
    pi_0 = niak_build_pi_0(grp,method);
else
    pi_0 = niak_build_pi_0(grp,method,q);
end