function [results,opt] = niak_network_fdr(model,part,opt)
% Network FDR testing of a general linear model on connectomes 
% Y = X.BETA + E 
%
% [RESULTS,OPT] = NIAK_GLM( MODEL , [OPT] )
%
% _________________________________________________________________________
% INPUTS:
%
% MODEL (structure) with the following fields:
%   Y (2D array size N*L) each row is a vectorized connectome for one subject.
%      the square form is of size MxM (see NIAK_MAT2LVEC).
%   X (2D array size N*C) each column of X is a explaining factor with the 
%      same number of rows as Y.
%   C (vector, size K*1) is a contrast vector (necessary unless OPT.TEST
%      is 'none').
%
% PART (vector MxP, default []) a partition of the units. PART(i,p) is the number of the cluster
%   for unit i in partition number p. Units have to be numbered from 1 to Kp 
%   (arbitrary Kp<=N). If left empty, partitions will be generated with hierarchical 
%   clustering (options can be set using OPT.NB_CLASSES and OPT.HIER below).
%
% OPT
%   (structure, optional) with the following fields:
%
%   METHOD (string, default 'LSL') the estimator of the proportion of true null 
%      hypothesis. 'TST' : The two-stage estimator; 'LSL' : the least-slope estimator.
%      See NIAK_BUILD_PI_0.
%   Q (scalar, default 0.05) the acceptable level of false-discovery rate.
%   FLAG_VERBOSE (boolean, default true) verbose progress information.
%   NB_CLASSES (vector of integer, default 10) the number of clusters in the partition. 
%      Multiple numbers can be specified.
%   HIER (structure, default 'Ward') the options of the hierarchical clustering. See
%      NIAK_HIERARCHICAL_CLUSTERING). 
%   NB_PERM (integer, default 1000) the number of permutations to estimate the omnibus test.
%   TEST (string, default 'none') the type of test to be applied.
%      Available options: 'ttest' , 'ftest', 'none'
%   FLAG_RSQUARE (boolean, default false) if the flag is true, the R2 statistics of the
%      regression is added to RESULTS (see below).
%   FLAG_RESIDUALS (boolean, default false) if the flag is true, the residuals E of the 
%      regression are added to RESULTS (see below).
%   FLAG_EFF (boolean, default false) if the flag is true, the estimated effects are 
%      added to RESULTS (i.e. the regression coefficients times the contrast).
%   FLAG_BETA (boolean, default false) if the flag is true, the regression coefficients
%      BETA are added to RESULTS (see below).
%
% _________________________________________________________________________
% OUTPUTS:
%
% RESULTS
%   (stucture) with the following fields:
%
%   BETA (vector size K*N) BETA(k,n) is the estimated coefficient regression 
%      estimate of X(:,k) on Y(:,n), using the least-square criterion.
%      See OPT.FLAG_BETA above.
%   E (2D array, size T*N) residuals of the regression. See OPT.FLAG_RESIDUALS above.
%   STD_E (vector, size [1 N]) STD_E(n) is an estimate of the standard deviation of
%      the noise Y(:,n). It is simply derived from the residual sum-of-squares
%      after correction for the number of degrees of freedom in the model.
%      (only available if OPT.TEST is 'ttest')
%   TTEST (vector, size [1 N]) TTEST(n) is a t-test associated with the estimated
%      weights and the specified contrast (see C above). (only available if 
%      OPT.TEST is 'ttest')
%   TEST_FDR (vector, size [1 N]) TEST_FDR(n) is 0 if the associated test does not 
%      reach significance at FDR level OPT.Q, and 1 otherwise.
%   FTEST (vector, size [1 N]) TTEST(n) is a F test associated with the estimated
%      weights and the specified contrast (see C above). (only available if 
%      OPT.TEST is 'ftest')
%   PCE (vector,size [1 N]) PCE(n) is the per-comparison error associated with 
%      TTEST(n) (bilateral test). (only available if OPT.TEST is 'ttest')
%   DEGFREE (scalar value) is the degrees of freedom left after regression.
%      Will be 2 scalar values for ftest.
%   EFF (vector, size [1 N]) the effect associated with the contrast and the 
%      regression coefficients (only available if OPT.TEST is 'ttest')
%   STD_EFF (vector, size [1 N]) STD_EFF(n) is the standard deviation of the effect
%      EFF(n).
%   RSQUARE (vector, size 1*N) The R2 statistics of the model (percentage of sum-of-squares
%      explained by the model).
%
% _________________________________________________________________________
% REFERENCES:
%
% On the estimation of coefficients and the t-test:
%
%   Statistical Parametric Mapping: The Analysis of Functional Brain Image.
%   Edited By William D. Penny, Karl J. Friston, John T. Ashburner,
%   Stefan J. Kiebel  &  Thomas E. Nichols. Springer, 2007.
%   Chapter 7: "The general linear model", S.J. Kiebel, A.P. Holmes.
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
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec
% Centre de recherche de l'Institut universitaire de gériatrie de Montréal, 2014.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : Statistics, General Linear Model, connectomes, adaptive FDR

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
if (nargin<2)||(isempty(opt))
    opt = struct([]);
end

%% Default options
list_fields    = { 'nb_classes' , 'hier'   , 'q'  , 'method' , 'nb_samps' , 'flag_verbose' , 'flag_rsquare' , 'flag_eff' , 'flag_residuals' , 'flag_beta', 'test' };
list_defaults  = { 10           , struct() , 0.05 , 'LSL'    , 1000       , true           , false         , false     , false           , false      , 'none' };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

opt_glm = rmfield(opt,{'nb_classes','hier','q','method','nb_samps','flag_verbose'}); % the options for niak_glm

%% Generate the partitions, if necessary
if (nargin<2)||isempty(part)
    opt_hier = opt.hier;
    opt_hier.flag_verbose = false;
    R = niak_lvec2mat(mean(model.y,1));
    hier = niak_hierarchical_clustering(R,opt_hier);
    order = niak_hier2order(hier);
    part = niak_threshold_hierarchy(hier,struct('thresh',opt.nb_classes));
end

%% Run the tests
res = niak_glm(model,opt_glm);

%% Estimate pi_0
pi_0 = cell(size(part,2),1);
for pp = 1:size(part,2)    
    pi_0{pp} = niak_build_pi_0(res.pce,part(:,pp),opt.method,opt.q);
end

%% Run permutation tests
pce_null = zeros(opt.nb_samps,length(res.pce));
for ss = 1:opt.nb_samps
    if opt.flag_verbose
        niak_progress(ss,opt.nb_samps);
    end
    model_null = niak_permutation_glm(model);
    res_null = niak_glm(model_null,opt_glm);
    pce_null(ss,:) = res_null.pce;
end

%% Estimate pi_0 over replications
pi_0_null = cell(size(part,2),1);
for pp = 1:size(part,2)
    pi_0_null{pp} = niak_build_pi_0(pce_null,part(:,pp),opt.method,opt.q);
end

%% Omnibus test
for pp = 1:size(part,2)
    pce_omnibus{pp} = (sum(pi_0_null{pp}<=repmat(pi_0{pp},[opt.nb_samps 1]),1)+1)/(opt.nb_samps + 1);
end

%% Run network tests
for pp = 1:size(part,2)
    pi_0{pp}(pce_omnibus{pp}>=(opt.q/length(pce_omnibus{pp}))) = 1; % shrink the estimation of the proportion of true null towards 1
    test_fdr{pp} = niak_group_fdr(res.pce,pi_0{pp},opt.q);
end
