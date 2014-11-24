clear all
addpath(genpath('/home/atam/quarantaine/niak-boss-0.12.18'));
path_data = '/gs/scratch/atam/';

%%% ADNET GLM CONNECTOME SCRIPT - MAIN CONTRASTS - basc 40 scales -
%%% NOTE: MONTREAL SITES FOR CNE ONLY

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

%%%%%%%%%%%%
%% Grabbing the results from BASC
%%%%%%%%%%%%
files_in = niak_grab_stability_rest([path_data 'adnet/basc_40sc_20141031/']); % a subset of 5 scales (10, 20, 50, 100, 200)

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol = 50;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
opt_g.filter.session = {'session1'};



%belleville aka ad_criugm
files_in.fmri = niak_grab_fmri_preprocess([path_data 'ad_mtl/belleville/fmri_preprocess/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%mni_mci
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'ad_mtl/mni_mci/fmri_preprocess/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

%adpd
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'ad_mtl/adpd/fmri_preprocess/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

%criugm_mci
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'ad_mtl/criugm_mci/fmri_preprocess/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);


%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = [path_data 'adnet/models/admci_model_multisite_fd_20141031.csv'];

%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = [path_data 'adnet/results/glm26_20141124']; % Where to store the results
opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

%% Group differences in controls per site

%%% ad_crigum vs criugm_mci

opt.test.adcriugmvscriugmmci.group.contrast.ad_criugm = 1; 
opt.test.adcriugmvscriugmmci.group.contrast.age = 0;     
opt.test.adcriugmvscriugmmci.group.contrast.gender = 0;
opt.test.adcriugmvscriugmmci.group.contrast.fd = 0;
opt.test.adcriugmvscriugmmci.group.select(1).label = 'ad_criugm'; 
opt.test.adcriugmvscriugmmci.group.select(1).values = 1;
opt.test.adcriugmvscriugmmci.group.select(2).label = 'criugm_mci'; 
opt.test.adcriugmvscriugmmci.group.select(2).values = 1;
opt.test.adcriugmvscriugmmci.group.select(2).operation = 'or';
opt.test.adcriugmvscriugmmci.group.select(3).label = 'diagnosis'; 
opt.test.adcriugmvscriugmmci.group.select(3).values = 1;
opt.test.adcriugmvscriugmmci.group.select(3).operation = 'and';



%%% ad_criugm vs adpd

opt.test.adcriugmvsadpd.group.contrast.ad_criugm = 1; 
opt.test.adcriugmvsadpd.group.contrast.age = 0;     
opt.test.adcriugmvsadpd.group.contrast.gender = 0;
opt.test.adcriugmvsadpd.group.contrast.fd = 0;
opt.test.adcriugmvsadpd.group.select(1).label = 'ad_criugm'; 
opt.test.adcriugmvsadpd.group.select(1).values = 1;
opt.test.adcriugmvsadpd.group.select(2).label = 'adpd'; 
opt.test.adcriugmvsadpd.group.select(2).values = 1;
opt.test.adcriugmvsadpd.group.select(2).operation = 'or';
opt.test.adcriugmvsadpd.group.select(3).label = 'diagnosis'; 
opt.test.adcriugmvsadpd.group.select(3).values = 1;
opt.test.adcriugmvsadpd.group.select(3).operation = 'and';


%%% criugm_mci vs adpd

opt.test.criugmmcivsadpd.group.contrast.criugm_mci = 1; 
opt.test.criugmmcivsadpd.group.contrast.age = 0;     
opt.test.criugmmcivsadpd.group.contrast.gender = 0;
opt.test.criugmmcivsadpd.group.contrast.fd = 0;
opt.test.criugmmcivsadpd.group.select(1).label = 'ad_criugm'; 
opt.test.criugmmcivsadpd.group.select(1).values = 1;
opt.test.criugmmcivsadpd.group.select(2).label = 'adpd'; 
opt.test.criugmmcivsadpd.group.select(2).values = 1;
opt.test.criugmmcivsadpd.group.select(2).operation = 'or';
opt.test.criugmmcivsadpd.group.select(3).label = 'diagnosis'; 
opt.test.criugmmcivsadpd.group.select(3).values = 1;
opt.test.criugmmcivsadpd.group.select(3).operation = 'and';

%%% mnimci vs ad_criugm

opt.test.mnimcivsadcriugm.group.contrast.mnimci = 1; 
opt.test.mnimcivsadcriugm.group.contrast.age = 0;     
opt.test.mnimcivsadcriugm.group.contrast.gender = 0;
opt.test.mnimcivsadcriugm.group.contrast.fd = 0;
opt.test.mnimcivsadcriugm.group.select(1).label = 'mnimci'; 
opt.test.mnimcivsadcriugm.group.select(1).values = 1;
opt.test.mnimcivsadcriugm.group.select(2).label = 'ad_criugm'; 
opt.test.mnimcivsadcriugm.group.select(2).values = 1;
opt.test.mnimcivsadcriugm.group.select(2).operation = 'or';
opt.test.mnimcivsadcriugm.group.select(3).label = 'diagnosis'; 
opt.test.mnimcivsadcriugm.group.select(3).values = 1;
opt.test.mnimcivsadcriugm.group.select(3).operation = 'and';

%%% mnimci vs criugm_mci

opt.test.mnimcivscriugmmci.group.contrast.mnimci = 1; 
opt.test.mnimcivscriugmmci.group.contrast.age = 0;     
opt.test.mnimcivscriugmmci.group.contrast.gender = 0;
opt.test.mnimcivscriugmmci.group.contrast.fd = 0;
opt.test.mnimcivscriugmmci.group.select(1).label = 'mnimci'; 
opt.test.mnimcivscriugmmci.group.select(1).values = 1;
opt.test.mnimcivscriugmmci.group.select(2).label = 'criugm_mci'; 
opt.test.mnimcivscriugmmci.group.select(2).values = 1;
opt.test.mnimcivscriugmmci.group.select(2).operation = 'or';
opt.test.mnimcivscriugmmci.group.select(3).label = 'diagnosis'; 
opt.test.mnimcivscriugmmci.group.select(3).values = 1;
opt.test.mnimcivscriugmmci.group.select(3).operation = 'and';

%%% mnimci vs adpd

opt.test.mnimcivsadpd.group.contrast.mnimci = 1; 
opt.test.mnimcivsadpd.group.contrast.age = 0;     
opt.test.mnimcivsadpd.group.contrast.gender = 0;
opt.test.mnimcivsadpd.group.contrast.fd = 0;
opt.test.mnimcivsadpd.group.select(1).label = 'mnimci'; 
opt.test.mnimcivsadpd.group.select(1).values = 1;
opt.test.mnimcivsadpd.group.select(2).label = 'adpd'; 
opt.test.mnimcivsadpd.group.select(2).values = 1;
opt.test.mnimcivsadpd.group.select(2).operation = 'or';
opt.test.mnimcivsadpd.group.select(3).label = 'diagnosis'; 
opt.test.mnimcivsadpd.group.select(3).values = 1;
opt.test.mnimcivsadpd.group.select(3).operation = 'and';


% %% Group averages for controls only
% 
% 
% %%% ad_criugm avg connectivity
% 
opt.test.ad_criugm_avg_ctrl.group.contrast.intercept = 1;
opt.test.ad_criugm_avg_ctrl.group.contrast.age = 0;
opt.test.ad_criugm_avg_ctrl.group.contrast.gender = 0;
opt.test.ad_criugm_avg_ctrl.group.contrast.fd = 0;
opt.test.ad_criugm_avg_ctrl.group.select(1).label = 'ad_criugm'; 
opt.test.ad_criugm_avg_ctrl.group.select(1).values = 1;
opt.test.ad_criugm_avg_ctrl.group.select(2).label = 'diagnosis';
opt.test.ad_criugm_avg_ctrl.group.select(2).values = 1;
opt.test.ad_criugm_avg_ctrl.group.select(2).operation = 'and';
% 
% 
% % 
% % %%% crigum_mci avg connectivity
opt.test.criugm_mci_avg_ctrl.group.contrast.intercept = 1;
opt.test.criugm_mci_avg_ctrl.contrast.age = 0;
opt.test.criugm_mci_avg_ctrl.contrast.gender = 0;
opt.test.criugm_mci_avg_ctrl.contrast.fd = 0;
opt.test.criugm_mci_avg_ctrl.group.select(1).label = 'criugm_mci'; 
opt.test.criugm_mci_avg_ctrl.group.select(1).values = 1;
opt.test.criugm_mci_avg_ctrl.group.select(2).label = 'diagnosis';
opt.test.criugm_mci_avg_ctrl.group.select(2).values = 1;
opt.test.criugm_mci_avg_ctrl.group.select(2).operation = 'and';
% 
% % 
% % %%% adpd avg connectivity 
opt.test.adpd_avg_ctrl.group.contrast.intercept = 1;
opt.test.adpd_avg_ctrl.contrast.age = 0;
opt.test.adpd_avg_ctrl.contrast.gender = 0;
opt.test.adpd_avg_ctrl.contrast.fd = 0;
opt.test.adpd_avg_ctrl.group.select(1).label = 'adpd'; 
opt.test.adpd_avg_ctrl.group.select(1).values = 1;
opt.test.adpd_avg_ctrl.group.select(2).label = 'diagnosis';
opt.test.adpd_avg_ctrl.group.select(2).values = 1;
opt.test.adpd_avg_ctrl.group.select(2).operation = 'and';

%%% mnimci avg connectivity
opt.test.mnimci_avg_ctrl.group.contrast.intercept = 1;
opt.test.mnimci_avg_ctrl.contrast.age = 0;
opt.test.mnimci_avg_ctrl.contrast.gender = 0;
opt.test.mnimci_avg_ctrl.contrast.fd = 0;
opt.test.mnimci_avg_ctrl.group.select(1).label = 'mnimci'; 
opt.test.mnimci_avg_ctrl.group.select(1).values = 1;
opt.test.mnimci_avg_ctrl.group.select(2).label = 'diagnosis';
opt.test.mnimci_avg_ctrl.group.select(2).values = 1;
opt.test.mnimci_avg_ctrl.group.select(2).operation = 'and';




%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
% opt.psom.qsub_options= '-A gsf-624-aa -q sw -l nodes=1:ppn=2 -l walltime=30:00:00';
% opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt); 

