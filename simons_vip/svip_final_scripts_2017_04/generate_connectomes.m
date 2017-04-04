clear;
% We will run stuff with singularity
base_path = '/gs/project/gsf-624-aa/simons_vip/';
preproc_path = [base_path filesep 'preproc/svip_prep_final'];

% exclude subjects that failed light QC: 
opt_g.exclude_subject = {'s14725xx46xFCAP1','s14785xx5xFCAP1', 's14871xx1xFCAP1', 's14927xx1xFCAP1', 's14928xx1xFCAP1', 's14983xx1xFCAP1'};
% the demo dataset is very short, so we have to lower considerably the minimum acceptable number of volumes per run
opt_g.min_nb_vol = 40; 
%opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline
opt_g.type_files = 'roi'; %
% Decide if we use only one session or combine them (comment out)
% opt_g.filter.session = {'session1'};
% Most recent and confident preprocessing
files_in = niak_grab_fmri_preprocess(preproc_path, opt_g);

% Define the network template to use
files_in.network = [base_path 'template/template_cambridge_basc_multiscale_asym_scale012.nii.gz'];
% Let's create a csv file that contains the assignment of network number to network names
files_in.seeds = [base_path 'list_seeds.csv'];
opt_csv.labels_x = {'Basal_Ganglia',... 
		'Auditory',...
	       	'Limbic',...
	       	'Lateral_DMN',...
	       	'Visual',...
	       	'Post_medial_DMN',...
	       	'Somatomotor',...
	       	'Ant_DMN',...
	       	'Upstream_visual',...
	       	'Fronto_parietal',...
	       	'Ventral_att',...
	       	'Cerebellum'}; 
opt_csv.labels_y = { 'index' };
tab = (1:12)';
niak_write_csv(files_in.seeds,tab,opt_csv);

% Set the options for the pipeline
opt.folder_out = [base_path filesep 'connectomes/cambridge012'];
opt.flag_p2p = false; % No parcel-to-parcel correlation values TODO: ask what this thing does
opt.flag_global_prop = false; % No global graph properties
opt.flag_local_prop  = false; % No local graph properties
opt.flag_rmap = true; % Generate correlation maps
opt.flag_test = false; 
[pipeline,opt] = niak_pipeline_connectome(files_in,opt); 
