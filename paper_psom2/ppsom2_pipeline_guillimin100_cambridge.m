#!octave
path_database = '/gs/scratch/pbellec/psom2/';
path_mnc      = [path_database 'cambridge_raw/'];
path_preprocess = [path_database 'cambridge_preproc_gui_100/'];

opt.folder_out = path_preprocess;
opt.size_output = 'quality_control';
opt.motion_correction.suppress_vol = 0; 
opt.time_filter.hp = 0.01;
opt.corsica.sica.nb_comp = 50;
opt.corsica.threshold = 0.15;
opt.corsica.flag_skip = false;
opt.resample_vol.voxel_size = 3;
opt.smooth_vol.fwhm = 6;
opt.t1_preprocess.nu_correct.arg = '-distance 50';
opt.slice_timing.delay_in_tr = 0;
opt.slice_timing.type_scanner = 'Siemens';
opt.slice_timing.type_acquisition = 'interleaved';

list_subject = fcon_read_demog([path_mnc 'Cambridge_demographics.txt']);
opt_g.path_database = path_mnc;
files_in = fcon_get_files(list_subject,opt_g);

opt.psom.max_queued = 100;
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt); 
