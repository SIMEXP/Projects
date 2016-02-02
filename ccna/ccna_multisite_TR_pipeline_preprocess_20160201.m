 
clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.4/'))


path_raw       = '/gs/project/gsf-624-aa/database2/ccna/ccna_20160201_mnc/';
path_preprocess     = '/gs/project/gsf-624-aa/database2/ccna_multisite_TR_preprocess_20160201/';


sites  = {'CHUS','CINQ','UNF','MNI'};

for s = 1:length(sites)
    site = sites{s};
    
    %anat
    fmrirun = dir([path_raw filesep site filesep site '_1' filesep 'anat' filesep '*.mnc']);
    anat = [path_raw filesep site filesep site '_1' filesep 'anat' filesep fmrirun.name];
    
    %session1
    fmrirun = dir([path_raw filesep site filesep site '_1' filesep 'rest' filesep '*.mnc']);
    fmri.session1.run1 = [path_raw filesep site filesep site '_1' filesep 'rest' filesep fmrirun.name];
    
    %session2
    fmrirun = dir([path_raw filesep site filesep site '_2' filesep 'rest' filesep '*.mnc']);
    fmri.session2.run1 = [path_raw filesep site filesep site '_2' filesep 'rest' filesep fmrirun.name];
    
    if s == 4 % MNI
        
    %session3
    fmrirun = dir([path_raw filesep site filesep site '_3' filesep 'rest4' filesep '*.mnc']);
    fmri.session3.run1 = [path_raw filesep site filesep site '_3' filesep 'rest4' filesep fmrirun.name]; 
    
    fmrirun = dir([path_raw filesep site filesep site '_3' filesep 'rest45' filesep '*.mnc']);
    fmri.session3.run2 = [path_raw filesep site filesep site '_3' filesep 'rest45' filesep fmrirun.name]; 
    
    fmrirun = dir([path_raw filesep site filesep site '_3' filesep 'rest5' filesep '*.mnc']);
    fmri.session3.run3 = [path_raw filesep site filesep site '_3' filesep 'rest5' filesep fmrirun.name]; 
    end
    
    files_in.(site).anat = anat;
    files_in.(site).fmri = fmri;
end
        
    
%% Building the optional inputs
opt.folder_out = path_preprocess; 
opt.size_output = 'quality_control';

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

%% Slice timing
opt.slice_timing.type_acquisition = 'sequential ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Siemens';               % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes)
opt.slice_timing.flag_skip = 1;

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

%% Scrubbing
% opt.regress_confounds.flag_scrubbing = false;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generation of the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = 0;
%opt.psom.max_queued = 24; % Please try to use the two processors of my laptop, thanks !
%opt.granularity = 'subject';

[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);

