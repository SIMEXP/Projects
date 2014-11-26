function [files_in,files_out,opt] = netfdr_brick_simu_fdr(files_in,files_out,opt)
% Simulate changes in connectivity between two populations (with FDR)
%
% [FILES_IN,FILES_OUT,OPT] = NETFDR_BRICK_SIMU_FDR(FILES_IN,FILES_OUT,OPT)
%
% FILES_IN (structure, optional) not necessary unless OPT.TYPE_BACKGROUND = 'real'
%   MODEL (string) a model. Simulations will be generated through subsampling of this model.
%   PART (string) a .mat file with one or multiple partitions in an array PART 
%      (each column is a different partition). If left empty, the partitions will be 
%      estimated using (Ward's) hierarchical clustering and OPT.LIST_SCALES #clusters.
%
% FILES_OUT (string) the results of the simulation.
%
% OPT (structure) with the following fields.  
%   TYPE_BACKGROUND (string, default 'iid') the type of background data. 
%      'real': use real datasets for the null hypothesis. 
%      'iid': use independent Gaussin noise
%         in this case OPT.{THETA,N} below have to be specified.
%   THETA (scalar, default 1) the effect size.
%   LIST_SCALES (vector of integers) the list of scales used for testing. 
%   PI_LOW (scalar, default 0.1) the proportion of within- / between-cluster
%      showing an omnibus effect at low resolution.
%   PI_HIGH (scalar, default 0.2) the proportion of the tests within-/between-cluster
%      showing an effect at high resolution.
%   LIST_FDR (vector, default [0.01 0.05 0.1 0.2]) the levels of acceptable 
%      false-discovery rate for the t-maps.
%   NB_SUBJECT (integer) the number of subjects per group.
%   NB_PERM (integer, default 1000) the number of permutations to estimate the omnibus test.
%   RAND_SEED (scalar, default []) The specified value is used to seed the random
%      number generator with PSOM_SET_RAND_SEED. If left empty, no action
%      is taken.
%   NB_SAMPS (integer, default 100) the number of samples for the estimation of the 
%      effective FDR and sensitivity.
%   FLAG_VERBOSE (boolean, default 1) if the flag is 1, then the function 
%      prints some infos during the processing.
%   FLAG_TEST (boolean, default 0) if FLAG_TEST equals 1, the brick does not 
%      do anything but update the default values in FILES_IN, 
%      FILES_OUT and OPT.
%        
% NOTE: In the output, the structures FILES_IN, FILES_OUT and OPT are updated 
% with default valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%           
% Copyright (c) Pierre Bellec, 
% Centre de recherche de l'institut de gériatrie de Montréal, 2014.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : GLM-connectome, simulation

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

%% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NETFDR_BRICK_SIMU_FDR(FILES_IN,FILES_OUT,OPT).\n Type ''help netfdr_brick_simu_fdr'' for more info.')
end

%% Files in
list_fields   = { 'tseries' , 'part' };
list_defaults = { ''        , ''     };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);

%% Options
list_fields   = { 'pi_low' , 'pi_high' , 'nb_perm' , 'type_background' , 'theta' , 'nb_samps' , 'list_fdr'          , 'nb_subject' , 'rand_seed' , 'list_scales' , 'flag_verbose' , 'flag_test'  };
list_defaults = { 0.1      , 0.2       , 1000     , 'iid'             , 1       , 100        , [0.01 0.05 0.1 0.2] , 20           , []          , NaN           , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

if opt.scale_ref == 0
    opt.scale_ref = [];
end
        
%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Random number generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Read hierarchy
if ~isempty(files_in.part)
    part = load(files_in.part);
    part = part.part;
else  
    part = [];
end

%% Read time series
if ~isempty(files_in.model)
    model = load(files_in.model);
    model = model.model;
else
    model = struct;
end
if opt.flag_verbose
    fprintf('Generating simulations of group effects ...')
end

opt_simu.n = opt.n;
opt_simu.s = opt.nb_subject;
opt_simu.theta = opt.theta;

for num_samp = 1:opt.nb_samps
    if opt.flag_verbose
        niak_progress(num_samp,nb_samps);
    end
    if (num_samp == 1)
        [model,mask_true] = niak_simus_glm_connectome(opt_simu);
    else
        model = niak_simus_glm_connectome(opt_simu);
    end
    for num_fdr = 1:length(list_fdr)
        opt_netfdr.q = list_fdr(num_fdr);
        opt_netfdr.flag_verbose = false;
        res = niak_network_fdr(model,part,opt_netfdr);
        if (num_samp == 1)&&(num_fdr==1)
            samps_fdrnet = zeros(nb_samps,length(res.ttest),length(list_fdr));
        end
        samps_fdrnet(num_samp,:,num_fdr) = res.test_fdr{1}; 
    end
end

%% Estimate effective FDR and sensitivity for network_fdr
fprintf('Evaluating NETFDR...\n'); 

res.sens = zeros(length(list_fdr),1);
res.fdr  = zeros(length(list_fdr),1);
for num_fdr=1:length(list_fdr)
    tp=sum(samps_netfdr(:,mask_true,num_fdr),2);
    nb_disc = sum(samps_netfdr(:,:,num_fdr),2);    
    res.sens(num_fdr)=mean(tp/sum(mask_true));
    tmp=tp./nb_disc;
    tmp(isnan(tmp))=1; 
    res.fdr(num_fdr)=mean(1-tmp);    
end 
if res.fdr(end)<max(list_fdr)
    res.fdr  = [res.fdr ; max(list_fdr) ]; 
    res.sens = [res.sens ; res.sens(end)]; 
end

%% Save results
save(files_out,'-struct','res')

