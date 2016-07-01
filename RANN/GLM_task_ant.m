%%% 
% based on demo GLM CONNECTOME SCRIPT and Angela Tam's "mcinet/mcinet_pipeline_MSPC_MSTEPS_2.m"
% SIMEXP - Pierre Bellec

clear all
%path_niak = ('/usr/local/niak/niak-v0.13/')
%addpath(genpath(path_niak))
path_data = '/home/perrine/scratch/RANN/';

%%%%%%%%%%%%
%% Grabbing the results from BASC
%%%%%%%%%%%%
files_in = niak_grab_stability_rest([path_data 'MSTEPS_task_synant4']); 

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol = 60;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
% opt_g.filter.session = {'session1'}; % Just grab session 1

%% select one task or another:
opt_g.filter.run = {'ant'}
%opt_g.filter.run = {'syn'}
% exclude subjects synonyms:
%opt_g.exclude_subject = {'P00004840'}
%opt_g.exclude_subject = {'P00002012', 'P00004654','P00004663','P00004694','P00004742','P00004743','P00004501','P00004551','P00004571','P00004636','P00004648','P00004719','P00004787','P00004797','P00004805','P00004825','P00004828'}
% exclude subjects antonyms:
opt_g.exclude_subject = {'P00004663','P00004694','P00004636','P00004743','P00004654','P00004819','P00004873','P00004239','P00004687','P00004639','P00004574','P00004656','P00004816','P00004742','P00004877','P00004731','P00004306','P00004721','P00004246','P00004549','P00004617','P00004794','P00004209'}
files_in.fmri = niak_grab_fmri_preprocess([path_data 'FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 


%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = [path_data 'BEHAV_all_filters_ant_syn.csv'];

%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = [path_data 'RANN_GLMconnectome/GLM_ant160625']; % Where to store the resultsb
opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

%% 1-Group differences: ageHvsL
%% 2-Group differences: education High vs Low

%%% 1- Using age group 3: 
%%age group 1 <50 vs age group 2 >50 (= age group #3)

%%% 2- test for education group :
%%%edu group 1 <16 edu group 2>=16

%%% 3- test for perforance group:
%%%Ant_Perf 0 <median for the group; 1 >= median for the group

%%% AGE
opt.test.ageYvsO.group.contrast.ageYvsO = 1; % define contrast of interest
opt.test.ageYvsO.group.contrast.education = 0; % regress out confounding variable
opt.test.ageYvsO.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.ageYvsO.group.contrast.FD_ant = 0; % regress out confounding variable
opt.test.ageYvsO.group.select(1).label = 'filter_in_ant'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.ageYvsO.group.select(1).values = 1;
%opt.test.eduHvsL.group.select(2).label = 'ageGroup3'; 
%opt.test.ageYvsO.group.select(2).values = [1 2];
%opt.test.ageYvsO.group.select(2).operation = 'and';

%%% EDUCATION
opt.test.eduHvsL.group.contrast.eduHvsL = 1; % define contrast of interest
%opt.test.eduHvsL.group.contrast.education = 0; % regress out confounding variable
opt.test.eduHvsL.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.eduHvsL.group.contrast.FD_ant = 0; % regress out confounding variable
opt.test.eduHvsL.group.select(1).label = 'filter_in_ant'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.eduHvsL.group.select(1).values = 1;

%%% PERFORMANCE
opt.test.perfHvsL.group.contrast.Ant_Perf = 1; % define contrast of interest
opt.test.perfHvsL.group.contrast.education = 0; % regress out confounding variable
opt.test.perfHvsL.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.perfHvsL.group.contrast.FD_ant = 0; % regress out confounding variable
opt.test.perfHvsL.group.select(1).label = 'filter_in_ant'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.perfHvsL.group.select(1).values = 1;

%%trial with intercept:
%opt.test.ageYvsO.group.contrast.intercept = 1; % define contrast of interest
%opt.test.ageYvsO.group.contrast.education = 0; % regress out confounding variable
%opt.test.ageYvsO.group.contrast.genderMF = 0; % regress out confounding variable
%opt.test.ageYvsO.group.contrast.FD_ant = 0; % regress out confounding variable
%opt.test.ageYvsO.group.select(1).label = 'filter_in_ant'; % select only antonym tasks (filtered on FD and perf criteria)
%opt.test.ageYvsO.group.select(1).values = 1;
%opt.test.eduHvsL.group.select(2).label = 'ageGroup3'; 
%opt.test.ageYvsO.group.select(2).values = [1 2];
%opt.test.ageYvsO.group.select(2).operation = 'and';

%% Group averages

%%% age group 1 (<50) average connectivity

opt.test.avg_one.group.contrast.intercept = 1; % define contrast of interest
%opt.test.avg_one.group.contrast.education = 0; % regress out confounding variable
opt.test.avg_one.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.avg_one.group.contrast.FD_ant = 0; % regress out confounding variable
opt.test.avg_one.group.select(1).label = 'filter_in_ant'; % select only antonyms
opt.test.avg_one.group.select(1).values = 1;
opt.test.avg_one.group.select(2).label = 'ageGroup3';
%opt.test.avg_one.group.select(2).label = 'edu_group';
opt.test.avg_one.group.select(2).values = 1;
opt.test.avg_one.group.select(2).operation = 'and';



%%% age group 2 (>50 )average connectivity
opt.test.avg_two.group.contrast.intercept = 1; % define contrast of interest
%opt.test.avg_two.group.contrast.education = 0; % regress out confounding variable
opt.test.avg_two.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.avg_two.group.contrast.FD_ant = 0; % regress out confounding variable
opt.test.avg_two.group.select(1).label = 'filter_in_ant'; % select only synonyms
opt.test.avg_two.group.select(1).values = 1;
opt.test.avg_two.group.select(2).label = 'ageGroup3';
%opt.test.avg_two.group.select(2).label = 'edu_group';
opt.test.avg_two.group.select(2).values = 2;
opt.test.avg_two.group.select(2).operation = 'and';


%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
opt.psom.max_queued =  200;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.
opt.time_between_checks = 60;
opt.psom.nb_resub = 3;  %verbose opt
%opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=3,pmem=3700m,walltime=36:00:00'; %so that workers stop beeing killed by walltime after 36h

[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);  
