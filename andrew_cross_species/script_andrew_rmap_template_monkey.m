clear

%% Add quarantaine 
addpath(genpath('/usr/local/quarantine/niak-boss-0.12.14'));
niak_gb_vars

%% Folder names
path_preproc = '/media/database8/nki_enhanced/fmri_preprocess/';
path_write = '/media/database8/nki_enhanced/rmap_template_monkey/';

%% Read subject list
file_subject = [path_write 'fmri_qc_subjects.csv'];
list_subject = niak_read_csv_cell(file_subject);

%% Grab preprocessing & templates
opt_g.min_nb_vol = 0;
opt_g.min_xcorr_func = -Inf;
opt_g.min_xcorr_anat = -Inf;
opt_g.include_subject = list_subject;
opt_g.filter.run = {'mx645'}; % Just grab the "rest" run
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
files_in.fmri = niak_grab_fmri_preprocess(path_preproc,opt_g).fmri;

%% Use the cambridge template 
files_in.network = [path_write filesep 'template_andrew_r1_masked.mnc.gz'];
files_in.seeds = [path_write filesep 'list_seeds_template_monkey.csv'];

%% Connectome options 
opt.connectome.type = 'Z'; % The type of connectome. See "help niak_brick_connectome" for more info. 
opt.connectome.thresh.type = 'sparsity_pos'; % The type of treshold used to binarize the connectome. See "help niak_brick_connectome" for more info. 
opt.connectome.thresh.param = 0.2; % the parameter of the thresholding. The actual definition depends of THRESH.TYPE:
opt.flag_p2p = false; % we just want rmaps
opt.flag_global_prop = false; % we just want rmaps
opt.flag_local_prop = false; % we just want rmaps

%% Pipeline options
opt.folder_out = path_write; % Where to store the results
[pipeline,opt] = niak_pipeline_connectome(files_in,opt); 