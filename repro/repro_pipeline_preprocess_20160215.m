 
clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-issue100/'))


path_raw       = '/gs/project/gsf-624-aa/database2/repro/data_mnc/';
path_preprocess     = '/gs/project/gsf-624-aa/database2/fmri_preproc_20160215/';


subjects_list = dir(path_raw);
subjects_list = subjects_list(3:end);

for num_s = 1:size(subjects_list,1)
    
    %% Subject file names
    subject = subjects_list(num_s).name
    
    %anat
    fmrirun = dir([path_raw filesep subject filesep 'session_1/anat_1' filesep '*.mnc.gz']);
    anat = [path_path_rawgroup filesep subject filesep 'session_1/anat_1' filesep fmrirun.name];
    
    %func
    fmrirun = dir([path_raw filesep subject filesep 'session_1/rest_1' filesep '*.mnc.gz']);
    fmri.session1.run1 = [path_raw filesep subject filesep 'session_1/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_2/rest_1' filesep '*.mnc.gz']);
    fmri.session2.run1 = [path_raw filesep subject filesep 'session_2/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_3/rest_1' filesep '*.mnc.gz']);
    fmri.session3.run1 = [path_raw filesep subject filesep 'session_3/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_4/rest_1' filesep '*.mnc.gz']);
    fmri.session4.run1 = [path_raw filesep subject filesep 'session_4/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_5/rest_1' filesep '*.mnc.gz']);
    fmri.session5.run1 = [path_raw filesep subject filesep 'session_5/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_6/rest_1' filesep '*.mnc.gz']);
    fmri.session6.run1 = [path_raw filesep subject filesep 'session_6/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_7/rest_1' filesep '*.mnc.gz']);
    fmri.session7.run1 = [path_raw filesep subject filesep 'session_7/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_8/rest_1' filesep '*.mnc.gz']);
    fmri.session8.run1 = [path_raw filesep subject filesep 'session_8/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_9/rest_1' filesep '*.mnc.gz']);
    fmri.session9.run1 = [path_raw filesep subject filesep 'session_9/rest_1' filesep fmrirun.name];
    
    fmrirun = dir([path_raw filesep subject filesep 'session_10/rest_1' filesep '*.mnc.gz']);
    fmri.session10.run1 = [path_raw filesep subject filesep 'session_10/rest_1' filesep fmrirun.name];
    
    
    files_in.(subject).fmri = fmri;
    files_in.(subject).anat = anat;
    
end


    
%% Building the optional inputs
opt.folder_out = path_preprocess; 
opt.size_output = 'quality_control';

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

%% Slice timing
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'GE';               % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes)
% opt.slice_timing.flag_center      = 1;
%% Motion correction (niak_brick_motion_correction)
%opt.motion_correction.suppress_vol = 0;             % Remove the first three dummy scans

%% Linear and non-linear fit of the anatomical image in the stereotaxic
%% space 
opt.t1_preprocess.nu_correct.arg = '-distance 50'; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 25 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

% T1-T2 coregistration (niak_brick_anat2func)
opt.anat2func.init = 'identity'; % An initial guess of the transform. Possible values 'identity', 'center'. 'identity' is self-explanatory. The 'center' option usually does more harm than good. Use it only if you have very big misrealignement between the two images (say, 2 cm).

%% Temporal filetring (niak_brick_time_filter)
opt.time_filter.hp = 0.01; % Apply a high-pass filter at cut-off frequency 0.01Hz (slow time drifts)
opt.time_filter.lp = Inf; % Do not apply low-pass filter. Low-pass filter induce a big loss in degrees of freedom without sgnificantly improving the SNR.

%% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp = 60;
opt.corsica.component_supp.threshold = 0.15;

%% Resampling in the stereotaxic space (niak_brick_resample_vol)
%opt.resample_vol.interpolation       = 'tricubic'; % The resampling scheme. The most accurate is 'sinc' but it is awfully slow
opt.resample_vol.voxel_size          = [3 3 3];    % The voxel size to use in the stereotaxic space

%% Spatial smoothing (niak_brick_smooth_vol)
opt.bricks.smooth_vol.fwhm = 6; % Apply an isotropic 6 mm gaussin smoothing.

%% Region growing
opt.region_growing.flag_skip = 1; % Turn on/off the region growing
%opt.template_fmri = '/home/cdansereau/svn/niak/trunk/template/roi_aal.mnc.gz';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generation of the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = 0;
%opt.psom.max_queued = 24; % Please try to use the two processors of my laptop, thanks !
%opt.granularity = 'subject';
opt_pipe.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=2,pmem=3700m,walltime=36:00:00';

[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);

