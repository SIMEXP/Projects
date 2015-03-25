clear all
addpath(genpath('/home/atam/quarantaine/niak-boss-0.12.18'));
path_data = '/gs/scratch/atam/';

%%% ADNET GLM CONNECTOME SCRIPT - MCI VS CONTROLS ONLY - basc 40 scales -
%%% NOTE: adpd only

%%
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
files_in = niak_grab_stability_rest([path_data 'adnet/basc_40sc_20141210/']); % a subset of 5 scales (10, 20, 50, 100, 200)

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol = 50;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
opt_g.filter.session = {'session1'};


%adpd
files_in.fmri = niak_grab_fmri_preprocess([path_data 'ad_mtl/adpd/fmri_preprocess/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 



%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = [path_data 'adnet/models/admci_model_multisite_fd_20141210.csv'];

%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = [path_data 'adnet/results/glm30adpd_20141211']; % Where to store the results
opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

%% Group differences

%%% ctlr vs mci

opt.test.ctrlvsmci.group.contrast.ctrlvsmci = 1; 
opt.test.ctrlvsmci.group.contrast.age = 0;     
opt.test.ctrlvsmci.group.contrast.gender = 0;
opt.test.ctrlvsmci.group.contrast.fd = 0;
opt.test.ctrlvsmci.group.select.label = 'diagnosis'; 
opt.test.ctrlvsmci.group.select.values = [1 2];




% %% Group averages
% 
% 
% %%% ctrl avg connectivity
% 
opt.test.avg_ctrl.group.contrast.intercept = 1;
opt.test.avg_ctrl.group.contrast.age = 0;
opt.test.avg_ctrl.group.contrast.gender = 0;
opt.test.avg_ctrl.group.contrast.fd = 0;
opt.test.avg_ctrl.group.select.label = 'diagnosis';
opt.test.avg_ctrl.group.select.values = 1;


% 
% %%% mci avg connectivity
opt.test.avg_mci.group.contrast.intercept = 1;
opt.test.avg_mci.group.contrast.age = 0;
opt.test.avg_mci.group.contrast.gender = 0;
opt.test.avg_mci.group.contrast.fd = 0;
opt.test.avg_mci.group.select.label = 'diagnosis';
opt.test.avg_mci.group.select.values = 2;







%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
% opt.psom.qsub_options= '-A gsf-624-aa -q sw -l nodes=1:ppn=2 -l walltime=30:00:00';
% opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt); 

