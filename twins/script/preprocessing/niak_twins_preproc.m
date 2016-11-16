% Create the inputs of and launch the NIAK_PIPELINE_FMRI_PREPROCESS on the
% specified dataset (RECONSOLIDATION dataset)
 clear 
clc 

path_raw_fmri   = '/gs/project/gsf-624-aa/twins/twins_study_raw/raw_mnc_EXP2/';
path_preprocess = '/gs/project/gsf-624-aa/twins/fmri_preprocess_EXP2_niak-0.17/';

%% Grab the raw data set

subjects_list = dir(path_raw_fmri);
subjects_list = {subjects_list.name};
subjects_list = subjects_list(~ismember(subjects_list,{'.','..'}));
%%  Subject names
    for nn = 1:length(subjects_list)
        subject = subjects_list{nn};
        subject_id = subject;
        subject_id(strfind(subject_id,"_"))="";
        subject_id(strfind(subject_id," "))="";
        fprintf('Subject %s\n',subject_id)
        
        subject_sessions = dir([path_raw_fmri filesep subject]);
        subject_sessions = {subject_sessions.name};
        subject_sessions = subject_sessions(~ismember(subject_sessions,{'.','..'}));
        
%%      Subject sessions names
        for ss = 1:length(subject_sessions)
            session = subject_sessions{ss};
            fprintf('    session %s\n',session)
%%          Adding the subject to the list of files
            path_fmri = [path_raw_fmri subject filesep session filesep];
            path_anat = [path_raw_fmri subject filesep session filesep];
            files_in.(subject_id).fmri.(["sess" num2str(ss)]).run1 = [path_fmri dir([path_fmri "func_*"]).name];
            files_in.(subject_id).anat=[path_anat dir([path_anat "anat_*"]).name];

        end
    end

%% Building the optional inputs
opt.folder_out = path_preprocess;
opt.size_output = 'quality_control';

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

%% Slice timing

opt.slice_timing.flag_even_odd = true; % equalize the difference in terms of signal intensity between odd and even slices
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Siemens';               % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes) tr =  2.6500
opt.slice_timing.suppress_vol = 3; % Remove the first three dummy scans

%% Linear and non-linear fit of the anatomical image in the stereotaxic
%% space
opt.t1_preprocess.nu_correct.arg = '-distance 200'; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 25 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

% T1-T2 coregistration (niak_brick_anat2func)
opt.anat2func.init = 'identity'; % An initial guess of the transform. Possible values 'identity', 'center'. 'identity' is self-explanatory. The 'center' option usually does more harm than good. Use it only if you have very big misrealignement between the two images (say, 2 cm).

%% Resampling in the stereotaxic space (niak_brick_resample_vol) 3.3063   3.3063   4.9211 # 3.3298   3.3298   4.9559 # 3.2370   3.2370   4.8179
opt.resample_vol.interpolation       = 'trilinear'; % The resampling scheme. The most accurate is 'sinc' but it is awfully slow
opt.resample_vol.voxel_size          = [3 3 3];    % The voxel size to use in the stereotaxic space

%motion+
opt.regress_confounds.flag_wm = true;
opt.regress_confounds.flag_vent = true;
opt.regress_confounds.flag_motion_params = true;
opt.regress_confounds.flag_scrubbing = true;
opt.regress_confounds.thre_fd = 0.5;

% multivar
opt.regress_confounds.flag_gsc = false;          % Turn on/off the regression of the PCA-based estimation of the global signal (true: apply / false : don't apply)

%% Temporal filetring (niak_brick_time_filter)
opt.time_filter.hp = 0.01; % Apply a high-pass filter at cut-off frequency 0.01Hz (slow time drifts)
opt.time_filter.lp = Inf; % Do not apply low-pass filter. Low-pass filter induce a big loss in degrees of freedom without sgnificantly improving the SNR.

%% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp = 60;
opt.corsica.flag_skip = true;
opt.corsica.component_supp.threshold = 0.15;

% Spatial smoothing (niak_brick_smooth_vol)
opt.smooth_vol.fwhm      = 6;  % Full-width at maximum (FWHM) of the Gaussian blurring kernel, in mm.
opt.smooth_vol.flag_skip = 0;  % Skip spatial smoothing (0: don't skip, 1 : skip)

%Tuning subjects:

opt.tune.subject = 'CJ2080359';
opt.tune.param.anat2func.init = 'center';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generation of the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%opt.psom.flag_pause = false;
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);

%% extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder

niak_gb_vars
system(['cp -ar ' gb_niak_path_niak ' '  opt.folder_out '.']); % make a copie of NIAK to output folder

save ([opt.folder_out 'pipeline_envir.mat']); % save pipeline envirement to output folder

