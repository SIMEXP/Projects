% Template to write a script for the NIAK fMRI preprocessing pipeline
% ADAPTED TO THE RANN DATASET (Perrine Ferre) 2015 05 05_TEST
%
% To run a demo of the preprocessing, please see
% NIAK_DEMO_FMRI_PREPROCESS.
%
% Copyright (c) Pierre Bellec, 
%   Montreal Neurological Institute, McGill University, 2008-2010.
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Quebec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, preprocessing, pipeline

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

%old-path-removed(unsatisfyingregistratio/slack-general-28092015):
%addpath(genpath('/sb/project/gsf-624-aa/quarantaine/niak-boss-0.13.0'))
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.4b'))

<<<<<<< HEAD
root_path = '/gs/project/gsf-624-aa/RANN/';
path_out = '/gs/scratch/perrine/RANN/preprocess_data_oct_2015_2/';

%% Grab the raw data
path_raw = [root_path 'raw_mnc/'];
list_subject = dir(path_raw);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..'}));
%only 40 subjects whose QC has been completed-to compare most recent NIAK13.0.2 release
%list_subject = list_subject([1 5 14 15 17 18 21 22 25 26 28 34 35 36 37 38 39 41 45 46 50 51 55 57 58 59 62 63 65 74 76 104 116 145 150 158 161 165 2031206 282]);

for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    tmp_path_subj = [path_raw subject filesep];
    files_in.(subject).anat = [];
    files_in.(subject).fmri.session1 = [];
    
    try 
        files_in.(subject).fmri.session1.ant = [tmp_path_subj dir([tmp_path_subj 'Ant_r1_' subject '_*.mnc.gz'])(1).name];
    catch exception
        warning ('The file %s does not exist, I suppressed that file from the pipeline %s','ant',subject);
    end

    try
        files_in.(subject).fmri.session1.syn = [tmp_path_subj dir([tmp_path_subj 'Syn_r1_' subject '_*.mnc.gz'])(1).name];
    catch exception
        warning ('The file %s does not exist, I suppressed that file from the pipeline %s','syn',subject);
    end

    try
        files_in.(subject).fmri.session1.pictname = [tmp_path_subj dir([tmp_path_subj 'PictName_r1_' subject '_*.mnc.gz'])(1).name];    
    catch exception
        warning ('The file %s does not exist, I suppressed that file from the pipeline %s','pictname',subject);
    end

    try
        files_in.(subject).fmri.session1.rest = [tmp_path_subj dir([tmp_path_subj 'REST_BOLD_' subject '_*.mnc.gz'])(1).name]; 
    catch exception
	warning ('The file %s does not exist, I suppressed that file from the pipeline %s','rest',subject);
    end

    try
        files_in.(subject).anat = [tmp_path_subj dir([tmp_path_subj 'T1_' subject '_*.mnc.gz'])(1).name];
    catch exception
        warning ('The file %s does not exist, I suppressed that subject %s','ANATOMIC',subject);
        files_in = rmfield(files_in,subject);
    end
    
    %inital loop command (but doesn't allow pipeline to run when single sub-files eg picnam is missing):
    %files_c = psom_files2cell(files_in.(subject).fmri.sess1);
    %for num_f = 1:length(files_c)
    %    if ~psom_exist(files_c{num_f})
    %        warning ('The file %s does not exist, I suppressed that file from the pipeline %s',files_c{num_f},subject);
    %        files_in.(subject).fmri.sess1 = rmfield(files_in.(subject).fmri.sess1,fieldnames(files_in.(subject).fmri.sess1)(num_f));
    %        break
    %    end        
    %end
    
    
    %files_c = psom_files2cell(files_in.(subject).anat);
    %for num_f = 1:length(files_c)
    %    if ~psom_exist(files_c{num_f})
    %        warning ('The file %s does not exist, I suppressed that subject %s',files_c{num_f},subject);
    %        files_in = rmfield(files_in,subject);
    %        break
    %    end        
    %end
    
    
end

% exclude PIC NAMING (only) for P00004507 and P00004563
files_in.P00004507.fmri.session1 = rmfield(files_in.P00004507.fmri.session1,'pictname');
files_in.P00004563.fmri.session1 = rmfield(files_in.P00004563.fmri.session1,'pictname');


%% WARNING: Do not use underscores '_' in the IDs of subject, sessions or runs. This may cause bugs in subsequent pipelines.

% Structural scan
%files_in.P00004801.anat                = '/home/perrine/Documents/RANNtest1_mnc/P00004801/S0001/T1/T1_P00004801_S0001.mnc';       
% fMRI run 1
%files_in.P00004801.fmri.session1.syn = '/home/perrine/Documents/RANNtest1_mnc/P00004801/S0001/Syn_r1/Syn_r1_P00004801_S0001.mnc';



%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%

%% General
% Where to store the results
opt.folder_out  = path_out;  % Where to store the results
opt.size_output = 'quality_control';                             % The amount of outputs that are generated by the pipeline. 'all' will keep intermediate outputs, 'quality_control' will only keep the quality control outputs. 

%% Pipeline manager 
%% It is recommended to edit a file psom_gb_vars_local.m based on psom_gb_vars.m located in the extensions/psom-rxxx/ subfolder of the NIAK folder 
%% See http://code.google.com/p/psom/wiki/ConfigurationPsom for more details
%% It is also possible to change the configuration of PSOM manually by uncommenting the following instructions:

%% Slice timing correction (niak_brick_slice_timing)
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Philips';                % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes)
opt.slice_timing.suppress_vol     = 0;                       % Number of dummy scans to suppress.
opt.slice_timing.flag_nu_correct  = 1;                       % Apply a correction for non-uniformities on the EPI volumes (1: on, 0: of). This is particularly important for 32-channels coil.
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
opt.regress_confounds.flag_scrubbing = false;     % Turn on/off the scrubbing of time frames with excessive motion (true: apply / false : don't apply)
opt.regress_confounds.thre_fd = 0.5;             % The threshold on frame displacement that is used to determine frames with excessive motion in the scrubbing procedure

% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp             = 60;    % Number of components estimated during the ICA. 20 is a minimal number, 60 was used in the validation of CORSICA.
opt.corsica.threshold                = 0.15;  % This threshold has been calibrated on a validation database as providing good sensitivity with excellent specificity.
opt.corsica.flag_skip                = 1;     % Skip CORSICA (0: don't skip, 1 : skip). Even if it is skipped, ICA results will be generated for quality-control purposes. The method is not currently considered to be stable enough for production unless it is manually supervised.

% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)

% how to specify a different parameter for two subjects (here subject1 and subject2)

%opt.tune(1).subject = 'P00004216';
%opt.tune(1).param.anat2func.init = 'center';
%opt.tune(2).subject = 'P00004225';
%opt.tune(2).param.anat2func.init = 'center';
%opt.tune(3).subject = 'P00004549';
%opt.tune(3).param.anat2func.init = 'center';
%opt.tune(4).subject = 'P00004577';
%opt.tune(4).param.anat2func.init = 'center';
%opt.tune(5).subject = 'P00004719';
%opt.tune(5).param.anat2func.init = 'center';
%opt.tune(6).subject = 'P00004744';
%opt.tune(6).param.anat2func.init = 'center';
%opt.tune(7).subject = 'P00004812';
%opt.tune(7).param.anat2func.init = 'center';
%opt.tune(8).subject = 'P00004507';
%opt.tune(8).param.anat2func.init = 'center';
%opt.tune(9).subject = 'P00004563';
%opt.tune(9).param.anat2func.init = 'center';

% Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param
%opt.tune(1).param.slice_timing.flag_center = true; % Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param
%opt.tune(2).subject = 'subject2';
%opt.tune(2).param.slice_timing.flag_center = false; % Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the fmri_preprocess pipeline  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% opt.psom.mode                  = 'batch'; % Process jobs in the background
% opt.psom.mode_pipeline_manager = 'batch'; % Run the pipeline manager in the background : if I unlog, keep working
opt.psom.max_queued              =  100;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.
opt.time_between_checks = 60;
%verbose opt
opt.psom.nb_resub = Inf; 
%so that workers stop beeing killed by walltime after 3h
opt.psom.qsub_options = '-q sw -l walltime=48:00:00';
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);
