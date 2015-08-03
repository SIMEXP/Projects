%%% Preprocessing script for ADNI2 dataset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% WARNING: Do not use underscores '_' in the IDs of subject, sessions or runs. This may cause bugs in subsequent pipelines.
clear all
addpath(genpath('/home/bellec_group/niak-boss-0.12.2/'));

input_folder = '/home/danserea/database/adni2/20131213_ADNI_RAW/';

files_in = adni2_grab_rawmnc(input_folder,[input_folder 'adni2_demographic_XXXXX.csv']);

%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%

%% General
opt.folder_out  = '/home/danserea/database/adni2/fmri_preprocess_02/';    % Where to store the results
opt.size_output = 'quality_control';                             % The amount of outputs that are generated by the pipeline. 'all' will keep intermediate outputs, 'quality_control' will only keep the quality control outputs. 

%% Pipeline manager 
%% It is recommended to edit a file psom_gb_vars_local.m based on psom_gb_vars.m located in the extensions/psom-rxxx/ subfolder of the NIAK folder 
%% See http://code.google.com/p/psom/wiki/ConfigurationPsom for more details
%% It is also possible to change the configuration of PSOM manually by uncommenting the following instructions:

% opt.psom.mode                  = 'batch'; % Process jobs in the background
% opt.psom.mode_pipeline_manager = 'batch'; % Run the pipeline manager in the background : if I unlog, keep working
% opt.psom.max_queued            = 4;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.

%% Slice timing correction (niak_brick_slice_timing)
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Philips';                % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes)
opt.slice_timing.suppress_vol     = 0;                       % Number of dummy scans to suppress.
opt.slice_timing.flag_nu_correct  = 0;                       % Apply a correction for non-uniformities on the EPI volumes (1: on, 0: of). This is particularly important for 32-channels coil.
opt.slice_timing.arg_nu_correct   = '-distance 200';         % The distance between control points for non-uniformity correction (in mm, lower values can capture faster varying slow spatial drifts).
opt.slice_timing.flag_center      = 0;                       % Set the origin of the volume at the center of mass of a brain mask. This is useful only if the voxel-to-world transformation from the DICOM header has somehow been damaged. This needs to be assessed on the raw images.
opt.slice_timing.flag_skip        = 0;                       % Skip the slice timing (0: don't skip, 1 : skip). Note that only the slice timing corretion portion is skipped, not all other effects such as FLAG_CENTER or FLAG_NU_CORRECT
 
% Motion estimation (niak_pipeline_motion)
opt.motion.session_ref  = 'session1'; % The session that is used as a reference. In general, use the session including the acqusition of the T1 scan.

% resampling in stereotaxic space
opt.resample_vol.interpolation = 'trilinear'; % The resampling scheme. The fastest and most robust method is trilinear. 
opt.resample_vol.voxel_size    = [3 3 3];     % The voxel size to use in the stereotaxic space
opt.resample_vol.flag_skip     = 0;           % Skip resampling (data will stay in native functional space after slice timing/motion correction) (0: don't skip, 1 : skip)

% Linear and non-linear fit of the anatomical image in the stereotaxic
% space (niak_brick_t1_preprocess)
opt.t1_preprocess.nu_correct.arg = '-distance 75'; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 75 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

% Temporal filtering (niak_brick_time_filter)
opt.time_filter.hp = 0.01; % Cut-off frequency for high-pass filtering, or removal of low frequencies (in Hz). A cut-off of -Inf will result in no high-pass filtering.
opt.time_filter.lp = Inf;  % Cut-off frequency for low-pass filtering, or removal of high frequencies (in Hz). A cut-off of Inf will result in no low-pass filtering.

% Regression of confounds and scrubbing (niak_brick_regress_confounds)
opt.regress_confounds.flag_wm = true;            % Turn on/off the regression of the average white matter signal (true: apply / false : don't apply)
opt.regress_confounds.flag_vent = true;          % Turn on/off the regression of the average of the ventricles (true: apply / false : don't apply)
opt.regress_confounds.flag_motion_params = true; % Turn on/off the regression of the motion parameters (true: apply / false : don't apply)
opt.regress_confounds.flag_gsc = false;          % Turn on/off the regression of the PCA-based estimation of the global signal (true: apply / false : don't apply)
opt.regress_confounds.flag_scrubbing = true;     % Turn on/off the scrubbing of time frames with excessive motion (true: apply / false : don't apply)
opt.regress_confounds.thre_fd = 0.2;             % The threshold on frame displacement that is used to determine frames with excessive motion in the scrubbing procedure

% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp             = 60;    % Number of components estimated during the ICA. 20 is a minimal number, 60 was used in the validation of CORSICA.
opt.corsica.threshold                = 0.15;  % This threshold has been calibrated on a validation database as providing good sensitivity with excellent specificity.
opt.corsica.flag_skip                = 1;     % Skip CORSICA (0: don't skip, 1 : skip). Even if it is skipped, ICA results will be generated for quality-control purposes. The method is not currently considered to be stable enough for production unless it is manually supervised.

% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)

% Flag center
opt.tune(1).subject = 'subject4021';
opt.tune(1).param.slice_timing = opt.slice_timing;
opt.tune(1).param.slice_timing.flag_center = true;

opt.tune(2).subject = 'subject4042';
opt.tune(2).param.slice_timing = opt.slice_timing;
opt.tune(2).param.slice_timing.flag_center = true;

opt.tune(3).subject = 'subject4194';
opt.tune(3).param.slice_timing = opt.slice_timing;
opt.tune(3).param.slice_timing.flag_center = true;

opt.tune(4).subject = 'subject4269';
opt.tune(4).param.t1_preprocess.nu_correct.arg = '-distance 50'; % param tested 75,50

opt.tune(5).subject = 'subject4511';
opt.tune(5).param.slice_timing = opt.slice_timing;
opt.tune(5).param.slice_timing.flag_center = true;

opt.tune(6).subject = 'subject4713';
opt.tune(6).param.slice_timing = opt.slice_timing;
opt.tune(6).param.slice_timing.flag_center = true; % Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param

opt.tune(7).subject = 'subject4192';
opt.tune(7).param.t1_preprocess.nu_correct.arg = '-distance 50'; % param tested 75,50

opt.tune(8).subject = 'subject4218';
opt.tune(8).param.slice_timing = opt.slice_timing;
opt.tune(8).param.slice_timing.flag_center = true;

opt.tune(9).subject = 'subject4473';
opt.tune(9).param.t1_preprocess.nu_correct.arg = '-distance 50'; % param tested 75,50

opt.tune(10).subject = 'subject5070';
opt.tune(10).param.t1_preprocess.nu_correct.arg = '-distance 50'; % param tested 75,50

opt.tune(11).subject = 'subject4713';
opt.tune(11).param.slice_timing = opt.slice_timing;
opt.tune(11).param.slice_timing.flag_center = true;

opt.tune(12).subject = 'subject4546';
opt.tune(12).param.slice_timing = opt.slice_timing;
opt.tune(12).param.slice_timing.flag_center = true;

opt.tune(13).subject = 'subject4171';
opt.tune(13).param.slice_timing = opt.slice_timing;
opt.tune(13).param.slice_timing.flag_center = true;

opt.tune(14).subject = 'subject4094';
opt.tune(14).param.slice_timing = opt.slice_timing;
opt.tune(14).param.slice_timing.flag_center = true;

opt.tune(15).subject = 'subject4251';
opt.tune(15).param.slice_timing = opt.slice_timing;
opt.tune(15).param.slice_timing.flag_center = true;

opt.tune(16).subject = 'subject4128';
opt.tune(16).param.slice_timing = opt.slice_timing;
opt.tune(16).param.slice_timing.flag_center = true;

opt.tune(17).subject = 'subject2373';
opt.tune(17).param.slice_timing = opt.slice_timing;
opt.tune(17).param.slice_timing.flag_center = true;

opt.tune(18).subject = 'subject4188';
opt.tune(18).param.slice_timing = opt.slice_timing;
opt.tune(18).param.slice_timing.flag_center = true;

opt.tune(19).subject = 'subject4422';
opt.tune(19).param.slice_timing = opt.slice_timing;
opt.tune(19).param.slice_timing.flag_center = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the fmri_preprocess pipeline  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);
