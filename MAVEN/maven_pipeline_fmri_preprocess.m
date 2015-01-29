%%% MAVEN preprocessing pipeline
% Script to run a preprocessing pipeline analysis on the HCP database.
%
% Copyright (c) Pierre Bellec, Yassine Benhajali
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
%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%
task  = 'inkscape_rest';
exp   = 'all';
%% Setting input/output files 
[status,cmdout] = system ('uname -n');
server          = strtrim(cmdout);
if strfind(server,'lg-1r') % This is guillimin
    root_path = '/gs/scratch/yassinebha/MAVEN/';
    fprintf ('server: %s (Guillimin) \n ',server)
    my_user_name = getenv('USER');
elseif strfind(server,'ip05') % this is mammouth
    root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2015/pbellec/benhajal/MAVEN/';
    fprintf ('server: %s (Mammouth) \n',server)
    my_user_name = getenv('USER');
else
    switch server
        case 'peuplier' % this is peuplier
        root_path = '/media/database6/MAVEN/';
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
        
        case 'noisetier' % this is noisetier
        root_path = '/media/database1/MAVEN/';
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% grab raw_data
path_raw = [root_path 'raw_mnc/'];
list_subject = dir(path_raw);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..','octave-wokspace','octave-core','qc_report.csv','D2026_20140809_134404541'}));
for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    id = subject(1:strfind(subject,'_')(1)-1);
    fprintf('Subject %s\n',id);
    path_anat = [path_raw subject filesep 'anat/'];
    anat_file = dir([path_anat "MPRAGEt1mprages*"]);
    switch anat_tmp = anat_file(ismember({anat_file.name},{'MPRAGEt1mprages009a1001.mnc.gz','MPRAGEt1mprages015a1001.mnc.gz',...
    'MPRAGEt1mprages011a1001.mnc.gz'})).name;  
          case 'MPRAGEt1mprages009a1001.mnc.gz'
          files_in.(id).anat=[path_anat 'MPRAGEt1mprages009a1001.mnc.gz'];
          case 'MPRAGEt1mprages015a1001.mnc.gz'
          files_in.(id).anat=[path_anat 'MPRAGEt1mprages015a1001.mnc.gz'];
          case 'MPRAGEt1mprages011a1001.mnc.gz'
          files_in.(id).anat=[path_anat 'MPRAGEt1mprages011a1001.mnc.gz'];
          otherwise
          warning('subject %s has no anat found', subject)
          files_in.(id).anat=[path_anat ''];
    end
    
    % subject runs
    subject_run = dir([path_raw subject filesep 'func/']);
    subject_run = {subject_run(3:end).name};   
    %loop over runs
    for num_run = 1:length(subject_run) 
        run_name = subject_run{num_run};
        path_func = [path_raw subject filesep 'func/'];
        func_file = dir([path_func run_name filesep  "RSN*"]);
        func_tmp = func_file(ismember({func_file.name},{'RSN1ep2d64s004a001.mnc.gz','RSN1ep2d64s010a001.mnc.gz',...
        'RSN1ep2d64s006a001.mnc.gz','RSN2ep2d64s005a001.mnc.gz','RSN2ep2d64s007a001.mnc.gz','RSN2ep2d64s011a001.mnc.gz',...
        'RSN3ep2d64s006a001.mnc.gz','RSN3ep2d64s008a001.mnc.gz','RSN3ep2d64s012a001.mnc.gz'})).name;
        
        switch func_tmp   
              case 'RSN1ep2d64s004a001.mnc.gz'
              files_in.(id).fmri.session1.rest1 = [path_raw subject filesep 'func/run1/RSN1ep2d64s004a001.mnc.gz'];
              case 'RSN1ep2d64s010a001.mnc.gz'
              files_in.(id).fmri.session1.rest1 = [path_raw subject filesep 'func/run1/RSN1ep2d64s010a001.mnc.gz'];
              case 'RSN1ep2d64s006a001.mnc.gz'
              files_in.(id).fmri.session1.rest1 = [path_raw subject filesep 'func/run1/RSN1ep2d64s006a001.mnc.gz'];
              case 'RSN2ep2d64s005a001.mnc.gz'
              files_in.(id).fmri.session1.inscape = [path_raw subject filesep 'func/run2/RSN2ep2d64s005a001.mnc.gz'];
              case 'RSN2ep2d64s007a001.mnc.gz'
              files_in.(id).fmri.session1.inscape = [path_raw subject filesep 'func/run2/RSN2ep2d64s007a001.mnc.gz'];
              case 'RSN2ep2d64s011a001.mnc.gz'
              files_in.(id).fmri.session1.inscape = [path_raw subject filesep 'func/run2/RSN2ep2d64s011a001.mnc.gz'];
              case 'RSN3ep2d64s006a001.mnc.gz'
              files_in.(id).fmri.session1.rest2 = [path_raw subject filesep 'func/run3/RSN3ep2d64s006a001.mnc.gz'];
              case 'RSN3ep2d64s008a001.mnc.gz'
              files_in.(id).fmri.session1.rest2 = [path_raw subject filesep 'func/run3/RSN3ep2d64s008a001.mnc.gz'];
              case 'RSN3ep2d64s012a001.mnc.gz'
              files_in.(id).fmri.session1.rest2 = [path_raw subject filesep 'func/run3/RSN3ep2d64s012a001.mnc.gz'];
              otherwise
              warning('subject %s has no functional found', subject)
              files_in.(id).fmri.session1.rest1 = [path_raw subject filesep ''];
        end
    end
end

files_c = psom_files2cell(files_in.(id));
for num_f = 1:length(files_c)
    if ~psom_exist(files_c{num_f})
        warning ('The file %s does not exist, I suppressed subject %s',files_c{num_f},subject);
        files_in = rmfield(files_in,id);
        break
    end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% General
opt.folder_out  = [root_path 'fmri_preprocess_' upper(task) '_' exp];    % Where to store the results
opt.size_output = 'quality_control';                             % The amount of outputs that are generated by the pipeline. 'all' will keep intermediate outputs, 'quality_control' will only keep the quality control outputs.


%% Slice timing correction (niak_brick_slice_timing)
opt.slice_timing.type_acquisition = 'interleaved descending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Siemens';                % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0.05;                       % The delay in TR ("blank" time between two volumes)
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
opt.regress_confounds.flag_wm            = true;            % Turn on/off the regression of the average white matter signal (true: apply / false : don't apply)
opt.regress_confounds.flag_vent          = true;          % Turn on/off the regression of the average of the ventricles (true: apply / false : don't apply)
opt.regress_confounds.flag_motion_params = true; % Turn on/off the regression of the motion parameters (true: apply / false : don't apply)
opt.regress_confounds.flag_gsc           = false;          % Turn on/off the regression of the PCA-based estimation of the global signal (true: apply / false : don't apply)
opt.regress_confounds.flag_scrubbing     = true;     % Turn on/off the scrubbing of time frames with excessive motion (true: apply / false : don't apply)
opt.regress_confounds.thre_fd            = 0.5;             % The threshold on frame displacement that is used to determine frames with excessive motion in the scrubbing procedure

% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp = 60;    % Number of components estimated during the ICA. 20 is a minimal number, 60 was used in the validation of CORSICA.
opt.corsica.threshold    = 0.15;  % This threshold has been calibrated on a validation database as providing good sensitivity with excellent specificity.
opt.corsica.flag_skip    = 1;     % Skip CORSICA (0: don't skip, 1 : skip). Even if it is skipped, ICA results will be generated for quality-control purposes. The method is not currently considered to be stable enough for production unless it is manually supervised.

% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)

% how to specify a different parameter for two subjects (here subject1 and subject2)
%  opt.tune(1).subject = 'subject1';
%  opt.tune(1).param.slice_timing.flag_center = true; % Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param
%  
%  opt.tune(2).subject = 'subject2';
%  opt.tune(2).param.slice_timing.flag_center = false; % Anything that usually goes in opt can go in param. What's specified in opt applies by default, but is overridden by tune.param

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the fmri_preprocess pipeline  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);

%% extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
