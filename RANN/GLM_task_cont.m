%%% 
% based on demo GLM CONNECTOME SCRIPT and Angela Tam's "mcinet/mcinet_pipeline_MSPC_MSTEPS_2.m"
% adapted to continuous variable
% SIMEXP - Pierre Bellec

clear all
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/')
addpath(genpath(path_niak))
path_data = '/home/perrine/scratch/RANN/'; %% GUILLIMIN
%%% path_data = '/home/pferr/RANN/'; %% MAGMA 

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
%opt_g.filter.run = {'ant'}
opt_g.filter.run = {'syn'}
opt_g.exclude_subject = {'P00004840'};%for some reason this participant generates fails in syn (voir GLM_cont_syn1)
opt_g.exclude_subject = {'P00002012','P00004209','P00004267','P00004310','P00004501','P00004551','P00004554','P00004567','P00004571','P00004572','P00004587','P00004617','P00004636','P00004648','P00004654','P00004656','P00004663','P00004666','P00004686','P00004687','P00004694','P00004719','P00004742','P00004743','P00004782','P00004787','P00004794','P00004797','P00004805','P00004828','P00004839','P00004874','P00004885'}
%opt_g.exclude_subject = {'P00004547','P00004663','P00004694','P00004636','P00004743','P00004654','P00004819','P00004873','P00004239','P00004574','P00004656','P00004816','P00004742','P00004877','P00004731','P00004306','P00004721','P00004895','P00004646','P00004246','P00002012','P00004841','P00004729','P00004803','P00004667','P00004714','P00004595','P00004343','P00004894','P00004526','P00004609','P00004690','P00004792','P00004861','P00004628','P00004523','P00004617','P00004794','P00004209','P00004356'}
%% participants excluded to obtain an FD match between age groups <50yo> and same N of participants in each age group

files_in.fmri = niak_grab_fmri_preprocess([path_data 'FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 


%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = [path_data 'BEHAV_all_filters_ant_syn.csv'];

%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = [path_data 'RANN_GLMconnectome/GLM_cont_syn6']; % Where to store the resultsb
opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

%% 1-Group differences: age
%% 2-Group differences: education 
%% 3- Group differences: performance
%% 4- interactions ?????

%%% AGE ANT
opt.test.age.group.contrast.age = 1; % define contrast of interest (age continuous only)
opt.test.age.group.contrast.education = 0; % regress out confounding variable
opt.test.age.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.age.group.contrast.FD_syn = 0; % regress out confounding variable
opt.test.age.group.select(1).label = 'filter_in_syn'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.age.group.select(1).values = 1;

%%% EDUCATION ANT
opt.test.edu.group.contrast.education = 1; % define contrast of interest
opt.test.edu.group.contrast.age = 0; % regress out confounding variable
opt.test.edu.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.edu.group.contrast.FD_syn = 0; % regress out confounding variable
opt.test.edu.group.select(1).label = 'filter_in_syn'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.edu.group.select(1).values = 1;

%%% PERFORMANCE ANT
opt.test.perf.group.contrast.SYN_NumCor100 = 1; % define contrast of interest
opt.test.perf.group.contrast.education = 0; % regress out confounding variable
opt.test.perf.group.contrast.age = 0; % regress out confounding variable
opt.test.perf.group.contrast.genderMF = 0; % regress out confounding variable
opt.test.perf.group.contrast.FD_syn = 0; % regress out confounding variable
opt.test.perf.group.select(1).label = 'filter_in_syn'; % select only antonym tasks (filtered on FD and perf criteria)
opt.test.perf.group.select(1).values = 1;


%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
opt.psom.max_queued =  200;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.
opt.time_between_checks = 90;
opt.psom.nb_resub = 3;  %verbose opt
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=3,pmem=3700m,walltime=36:00:00'; %so that workers stop beeing killed by walltime after 36h

[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);  
