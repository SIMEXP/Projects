% Run scores pipeline on full adni2 sample

clear all
addpath(genpath('/home/atam/git/niak'))
addpath(genpath('/home/atam/git/psom'))

% set up paths
path_data = '/gs/project/gsf-624-aa/data/adni2/fmri_preprocess/';
path_folder_out = '/home/atam/scratch/adni2/scores_20161206';

% set up file structure
opt_g.min_nb_vol = 50;     
opt_g.min_xcorr_func = 0;
opt_g.min_xcorr_anat = 0; 
opt_g.filter.session = {'session1'};
opt_g.type_files = 'scores';

files_in = niak_grab_fmri_preprocess(path_data,opt_g);
files_in.part = '/gs/project/gsf-624-aa/database2/preventad/templates/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
files_in.mask = '/gs/project/gsf-624-aa/database2/preventad/templates/mask.mnc.gz';

opt.folder_out = path_folder_out;
opt.psom.max_queued = 300;
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l walltime=03:00:00';
% opt.scores.flag_target = true;
% opt.scores.flag_deal = true;
pipeline = niak_pipeline_scores(files_in,opt);