#!/software/CentOS-6/applications/octave/3.8.1/bin/octave

%%% NKI_enhanced preprocessing pipeline
% Copyright (c) AmanPreet Badhwar
% Research Centre of the Montreal Geriatric Institute
% & Department of Computer Science and Operations Research
% University of Montreal, Québec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : fMRI, FIR, clustering, BASC
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

clear all
% load lib
% addpath adds folder to search path; genpath generates path string
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.3b/'))


%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%
exp   = 'all';
%task  = 'all';

%% Setting input/output files 
%% This is guillimin

%root_path = '/gs/project/gsf-624-aa/nki_multimodal_release1/';
%path_out = '/gs/project/gsf-624-aa/abadhwar/NKI_release1_attempt2/';
%root_path = '/gs/project/gsf-624-aa/nki_multimodal_release2/';
%path_out = '/gs/project/gsf-624-aa/abadhwar/NKI_release2_preprocessed/';
%root_path = '/gs/project/gsf-624-aa/nki_multimodal_release3/';
%path_out = '/gs/project/gsf-624-aa/abadhwar/NKI_release3_preprocessed/';

root_path = '/gs/project/gsf-624-aa/nki_multimodal_release4/';
path_out = '/gs/project/gsf-624-aa/abadhwar/NKI_release4_preprocessed/';

%% Grab the raw data
% note that '/gs/project/gsf-624-aa/nki_multimodal_releaseX/' contains the directory 'raw_mnc'
% assigns path_raw '/gs/project/gsf-624-aa/nki_multimodal_releaseX/raw_mnc/'
path_raw = [root_path 'raw_mnc/'];

% returns the folder listings of path_raw or '/gs/project/gsf-624-aa/nki_multimodal_releaseX/raw_mnc/' to list_subject
list_subject = dir(path_raw);

% returns the folder names to the variable list_subject
list_subject = {list_subject.name};

% ismember or array elements that are members of set array
list_subject = list_subject(~ismember(list_subject,{'.','..'}));



%% Run preprocessing on all subjects in NKI_release 4

%list_subject = list_subject([35:181]);
for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    id = ['s' subject];
    files_in.(id).anat = [path_raw subject filesep 'anat' filesep 'mprage.mnc.gz'];
    files_in.(id).fmri.sess1.breathHold1400 = [path_raw subject filesep 'TfMRI_breathHold_1400' filesep 'func.mnc.gz'];
    files_in.(id).fmri.sess1.checBoard1400 = [path_raw subject filesep 'TfMRI_visualCheckerboard_1400' filesep 'func.mnc.gz'];
    files_in.(id).fmri.sess1.checBoard645 = [path_raw subject filesep 'TfMRI_visualCheckerboard_645' filesep 'func.mnc.gz'];    
    
    files_in.(id).fmri.sess1.rest645 = [path_raw subject filesep 'session_1', filesep,'RfMRI_mx_645' filesep 'rest.mnc.gz'];
    files_in.(id).fmri.sess1.rest1400 = [path_raw subject filesep 'session_1', filesep,'RfMRI_mx_1400' filesep 'rest.mnc.gz'];
    files_in.(id).fmri.sess1.rest2500 = [path_raw subject filesep 'session_1', filesep,'RfMRI_std_2500' filesep 'rest.mnc.gz'];
    
    list_run = fieldnames(files_in.(id).fmri.sess1);
    flag_ok = true(length(list_run),1);
    for num_f = 1:length(list_run)
        run = list_run{num_f};
        if ~psom_exist(files_in.(id).fmri.sess1.(run))
            flag_ok(num_f) = false;
        end        
    end
    if ~any(flag_ok)||~psom_exist(files_in.(id).anat)
        if ~any(flag_ok)
            warning('No functional data for subject %s, I suppressed it',subject);
        else
            warning ('The file %s does not exist, I suppressed that subject %s',files_in.(id).anat,subject);
        end
        files_in = rmfield(files_in,id);
    elseif any(~flag_ok)
        files_in.(id).fmri.sess1 = rmfield(files_in.(id).fmri.sess1,list_run(~flag_ok));
        warning ('I suppressed the following runs for subject %s because the files were missing:',id);
        list_not_ok = find(~flag_ok);
        for ind_not_ok = list_not_ok(:)'
            fprintf(' %s',list_run{ind_not_ok});
        end
        fprintf('\n')
    end
end

% exclude subjects s0101463, s0103645, and s0103714
%files_in = rmfield(files_in, 's0101463');
%files_in = rmfield(files_in, 's0103645');
%files_in = rmfield(files_in, 's0103714');

%  warning: The file /media/database4/nki_enhanced/raw_mnc/0103714/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0103714
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0118439/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0118439
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0120538/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0120538
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0120652/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0120652
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0121498/anat/mprage.mnc.gz does not exist, I suppressed subject 0121498
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0141473/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0141473
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0144344/anat/mprage.mnc.gz does not exist, I suppressed subject 0144344
%  warning: The file /media/database4/nki_enhanced/raw_mnc/0148071/TfMRI_breathHold_1400/func.mnc.gz does not exist, I suppressed subject 0148071


%% Pipeline options  %%
%% General
opt.folder_out  = [path_out 'fmri_preprocess_' exp '_scrubb05'];    % Where to store the results
opt.size_output = 'quality_control';                             % The amount of outputs that are generated by the pipeline. 'all' will keep intermediate outputs, 'quality_control' will only keep the quality control outputs.

%% Pipeline manager 
%  opt.psom.qsub_options = '-q qwork@ms -l nodes=1:m32G,walltime=05:00:00';

%% Slice timing correction (niak_brick_slice_timing)
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Siemens';                % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes)
opt.slice_timing.suppress_vol     = 0;                       % Number of dummy scans to suppress.
opt.slice_timing.flag_nu_correct  = 1;                       % Apply a correction for non-uniformities on the EPI volumes (1: on, 0: of). This is particularly important for 32-channels coil.
opt.slice_timing.arg_nu_correct   = '-distance 200';         % The distance between control points for non-uniformity correction (in mm, lower values can capture faster varying slow spatial drifts).
opt.slice_timing.flag_center      = 0;                       % Set the origin of the volume at the center of mass of a brain mask. This is useful only if the voxel-to-world transformation from the DICOM header has somehow been damaged. This needs to be assessed on the raw images.
opt.slice_timing.flag_skip        = true;                    % Skip the slice timing (0: don't skip, 1 : skip). Note that only the slice timing corretion portion is skipped, not all other effects such as FLAG_CENTER or FLAG_NU_CORRECT
 
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
opt.regress_confounds.thre_fd = 0.5;             % The threshold on frame displacement that is used to determine frames with excessive motion in the scrubbing procedure

% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp             = 60;    % Number of components estimated during the ICA. 20 is a minimal number, 60 was used in the validation of CORSICA.
opt.corsica.threshold                = 0.15;  % This threshold has been calibrated on a validation database as providing good sensitivity with excellent specificity.
opt.corsica.flag_skip                = 1;     % Skip CORSICA (0: don't skip, 1 : skip). Even if it is skipped, ICA results will be generated for quality-control purposes. The method is not currently considered to be stable enough for production unless it is manually supervised.

% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tune the parameters for specific subjects %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%opt.tune(1).subject = 's0101463';
%opt.tune (1).param.slice_timing.arg_nu_correct = '-distance 100';
%opt.tune(1).param.slice_timing.flag_center = false;
%opt.tune(2).subject = 's0103645';
%opt.tune(2).param.slice_timing.arg_nu_correct = '-distance 100';
%opt.tune(2).param.slice_timing.flag_center = false;
%opt.tune(3).subject = 's0103714';
%opt.tune(3).param.slice_timing.arg_nu_correct = '-distance 100';
%opt.tune(3).param.slice_timing.flag_center = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the fmri_preprocess pipeline  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.psom.mode_pipeline_manager = 'background';
opt.psom.qsub_options = '-q sw -l nodes=1:ppn=2,pmem=3700m,walltime=36:00:00';
%opt.granularity = 'subject';
%opt.psom.max_queued = 100; (used for NKI_release1)
%opt.psom.max_queued = 14; (used for NKI_release2)
%opt.psom.max_queued = 46; (used for NKI_release3)
opt.psom.max_queued = 88;
opt.time_between_checks = 60;
opt.psom.nb_resub = Inf;
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);
