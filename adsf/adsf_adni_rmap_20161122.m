%% generate connectomes for all of adni2

clear all

path_data = '/home/atam/scratch/adni2/fmri_preprocess/fmri/';
path_template = '/gs/scratch/atam/template_cambridge_basc_multiscale_mnc_sym/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';
path_out = '/home/atam/scratch/rs_subtypes/adni2/';

% get names of files in directory
files = dir(path_data);
files = {files.name};
n_files = length(files);

%% set up files_in structure
files_in = struct;
for ss = 3:length(files)
      % Get the file name and path
      tmp = strsplit(files{ss},'_');
      sub_name = tmp{2};
      sub_date = tmp{4};
      files_in.fmri.(sub_name).sess1.rest = [path_data filesep sprintf('fmri_%s_session1_%s', sub_name, sub_date)];
end

files_in.network = path_template;

%% generate list of seeds
files_in.seeds = [path_out 'list_seeds.csv'];
opt_csv.labels_x = { 'net1' , 'net2' , 'net3' , 'net4' , 'net5' , 'net6' , 'net7' }; % The labels for the network
opt_csv.labels_y = { 'index' };
tab = [1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7];
niak_write_csv(files_in.seeds,tab,opt_csv);

opt.folder_out = path_out;
opt.flag_p2p = false; % No parcel-to-parcel correlation values
opt.flag_global_prop = false; % No global graph properties
opt.flag_local_prop  = false; % No local graph properties
opt.flag_rmap = true; % Generate correlation maps
opt.flag_test = false; 

[pipeline,opt] = niak_pipeline_connectome(files_in,opt);

