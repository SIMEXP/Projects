
clear
path_data = '/gs/scratch/pbellec/sbt_cobre/';
psom_mkdir(path_data)
cd(path_data)
path_cobre = '/gs/scratch/pbellec/cobre_fmri_preprocess_nii_20160921';

%% Grabbing the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = -Inf; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = -Inf; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
files_in.fmri = niak_grab_fmri_preprocess('path_cobre',opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%% Get the Cambridge template
[status,msg,data_template] = niak_wget('cambridge_template_mnc1');
files_in.network = [data_template.path filesep 'template_cambridge_basc_multiscale_sym_scale007.mnc.gz'];

%% Create a small file to select seeds
files_in.seeds = [path_data 'list_seeds.csv'];
opt_csv.labels_x = { 'CER' , 'LIMB' , 'MOTOR' , 'VIS' , 'vATT' , 'dATT' , 'DMN' }; % The labels for the network
opt_csv.labels_y = { 'index' };
tab = (1:7)';
niak_write_csv(files_in.seeds,tab,opt_csv);

opt.folder_out = [path_data 'connectome'];

opt.flag_p2p = false; % No parcel-to-parcel correlation values
opt.flag_global_prop = false; % No global graph properties
opt.flag_local_prop  = false; % No local graph properties
opt.flag_rmap = true; % Generate correlation maps

opt.flag_test = false; 
[pipeline,opt] = niak_pipeline_connectome(files_in,opt);