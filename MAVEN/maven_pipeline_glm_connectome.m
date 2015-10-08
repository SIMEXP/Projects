
%% script to run glm connectome pipelines on MAVEN dataset
clear all
%%%%%%%%%%%%
%% Grabbing the results from BASC
%%%%%%%%%%%%
opt_g_basc.level = 'group';
opt_g_basc.flag_tseries = false;
files_in = niak_grab_stability_rest('/home/yassinebha/scratch/MAVEN/basc_INSCAPE_REST_all',opt_g_basc);

%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%
opt_g.min_nb_vol = 30;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
%opt_g.filter.session = {'session1'}; % Just grab session 1
opt_g.exclude_subject = {'A1522b' 'D2354b'}; % exclude unwanted subjects
files_in.fmri = niak_grab_fmri_preprocess('/home/yassinebha/scratch/MAVEN/fmri_preprocess_INSCAPE_REST_all',opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored.

%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = '/home/yassinebha/scratch/MAVEN/model/maven_group_model.csv';

%% inter_run
subject_id = fieldnames(files_in.fmri);
for n = 1:length(subject_id)
    files_in.model.individual.(subject_id{n}).inter_run = '/home/yassinebha/scratch/MAVEN/model/maven_model_interrun.csv';
end


%%%%%%%%%%%%
%% Options
%%%%%%%%%%%%
opt.folder_out = '/home/yassinebha/scratch/MAVEN/maven_glm_scrub_20150810'; % Where to store the results
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
%opt.type_fdr = 'global';
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
% opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
% opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.nb_samps = 1000;
opt.nb_batch = 10;
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

% contrast rest1 vs inscape
opt.test.rest1VSinscape.inter_run.select(1).label    = 'rest1VSinscape' ;
opt.test.rest1VSinscape.inter_run.select(1).values = [1 -1] ;
opt.test.rest1VSinscape.inter_run.contrast.rest1VSinscape= 1 ;
opt.test.rest1VSinscape.group.contrast.FD = 0;

% contrast rest1 vs rest2
opt.test.rest1VSrest2.inter_run.select.label    = 'rest1VSrest2' ;
opt.test.rest1VSrest2.inter_run.select.values = [1 -1] ;
opt.test.rest1VSrest2.inter_run.contrast.rest1VSrest2= 1 ;
opt.test.rest1VSrest2.group.contrast.FD = 0;

% contrast rest2 vs inscape
opt.test.rest2VSinscape.inter_run.select.label    = 'rest2VSinscape' ;
opt.test.rest2VSinscape.inter_run.select.values = [1 -1] ;
opt.test.rest2VSinscape.inter_run.contrast.rest2VSinscape= 1 ;
opt.test.rest2VSinscape.group.contrast.FD = 0;

%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
%opt.psom.max_queued = 24; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);
