#!octave
path_database = '/home/bellecp1/database/psom2/';
path_mnc      = [path_database 'cambridge_raw/'];
path_preprocess = [path_database 'cambridge_preproc_mam_100/'];

opt.granularity = 'max';
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
opt.psom.nb_resub = 0;
opt.psom.flag_verbose = 1;
opt.psom.qsub_options = '-q qwork@ms -l walltime=12:00:00';
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt); 
