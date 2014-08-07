%% Meta Pipeline for running many simulations
clear;
%% Set the general parameters
path_test = niak_full_path('/home/surchs/Projects/stability_abstract/out/test_case2/');
file_data = [path_test 'data.mat'];
file_neigh = [path_test 'neigh.mat'];
file_ref = [path_test 'part_ref.mat'];

t = 100;
k = 16;
n = k^2;
% 6 steps each
fwhm = 2;
variance = 0.1;
scales_simulate = [4 16];
scales_investigate = 2:2:20;
% Set the simulation parameters
opt_s.type = 'checkerboard';
opt_s.t = t;
opt_s.n = n;
opt_s.nb_clusters = scales_simulate;
opt_s.fwhm = fwhm;
opt_s.variance = variance;
%% Generate the study data
% Generate the Neighbourhood Mask
mask = true(k);
neigh = niak_build_neighbour(mask, 6);
neigh_out = struct('neigh', neigh);

% Generate the reference partition
opt_ref = opt_s;
opt_ref.fwhm = 1;
opt_ref.variance = 1;
[ref_tseries, opt_sx] = niak_simus_scenario(opt_ref);
R_ref = niak_build_correlation(ref_tseries);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);
opt_ref = struct('thresh', scales_simulate);
part_ref = niak_threshold_hierarchy(hier_ref, opt_ref);

ref_out = struct('part', part_ref,...
                 'scale_tar', scales_simulate,...
                 'scale_rep', scales_simulate);

% Generate the simulated dataset
[data_tseries, opt_sx] = niak_simus_scenario(opt_s);
R_data = niak_build_correlation(data_tseries);
hier_data = niak_hierarchical_clustering(R_data);
order_data = niak_hier2order(hier_data);
data_out = struct('data', data_tseries,...
                  'order', order_ref);

%% Save the study data
if ~psom_exist(path_test)
    psom_mkdir(path_test);
end
if ~exist(file_neigh, 'file')
    save(file_neigh, '-struct', 'neigh_out');
    fprintf('Saved neighbourhood at %s\n', file_neigh);
else
    warning('%s already exists', file_neigh);
end

if ~exist(file_ref, 'file')
    save(file_ref, '-struct', 'ref_out');
    fprintf('Saved reference partition at %s\n', file_ref);
else
    warning('%s already exists', file_ref);
end

if ~exist(file_data, 'file')
    save(file_data, '-struct', 'data_out');
    fprintf('Saved data at %s\n', file_data);
else
    warning('%s already exists', file_data);
end

%% Commence testing runs
% Meta pipeline
meta_pipe = struct;
% Psom
% opt_meta.psom.qsub_options = '-q sw -l nodes=1:ppn=1,walltime=00:50:00';
opt_meta.psom.flag_pause = false;
opt_meta.psom.max_queued = 2;
opt_meta.path_logs = [path_test 'logs'];
% Testing options
opt_t = struct('name_data', 'data');
opt_t.sampling.type = 'scenario';
opt_t.sampling.opt = opt_s;
opt_t.stability_atom.nb_batch = 2;
opt_t.stability_vertex.nb_batch = 2;
opt_t.flag_rand = false;
opt_t.flag_verbose = true;
opt_t.flag_test = true;
opt_t.flag_cores = false;

% Data
in.data = file_data;
in.neigh = file_neigh;

%% External Partition Vanilla
% Set the name of the current simulation
simu_name = 'ext_vanilla';
target = 'manual';
% Set the inputs
in_test = in;
in_test.part = file_ref;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;

% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% External Partition Cores
% Set the name of the current simulation
simu_name = 'ext_cores';
target = 'manual';
% Set the inputs
in_test = in;
in_test.part = file_ref;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
opt_test.scale_grid = scales_simulate;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = true;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% External Partition Kcores Vanilla
% Set the name of the current simulation
simu_name = 'ext_kcores_vanilla';
target = 'manual';
% Set the inputs
in_test = in;
in_test.part = file_ref;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = false;
opt_test.stability_atom.clustering.type = 'kcores';
opt_test.stability_vertex.clustering.type = 'kcores';
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% External Partition Kcores Cores
% Set the name of the current simulation
simu_name = 'ext_kcores_cores';
target = 'manual';
% Set the inputs
in_test = in;
in_test.part = file_ref;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = true;
opt_test.scale_grid = scales_simulate;
opt_test.stability_atom.clustering.type = 'kcores';
opt_test.stability_vertex.clustering.type = 'kcores';
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Plugin Partition Vanilla
% Set the name of the current simulation
simu_name = 'plugin_vanilla';
target = 'plugin';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = false;
opt_test.scale_grid = scales_investigate;
opt_test.scale_tar = scales_investigate;
opt_test.scale_rep = scales_investigate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Plugin Cores
% Set the name of the current simulation
simu_name = 'plugin_cores';
target = 'plugin';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = true;
opt_test.scale_grid = scales_investigate;
opt_test.scale_tar = scales_investigate;
opt_test.scale_rep = scales_investigate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Consensus Find Vanilla
% Set the name of the current simulation
simu_name = 'cons_vanilla';
target = 'cons';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = false;
opt_test.scale_grid = scales_simulate;
opt_test.scale_tar = scales_simulate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Consensus Find Cores
% Set the name of the current simulation
simu_name = 'cons_cores';
target = 'cons';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = true;
opt_test.scale_grid = scales_investigate;
opt_test.scale_tar = scales_simulate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Consensus MSTEP Vanilla
% Set the name of the current simulation
simu_name = 'cons_mstep_vanilla';
target = 'cons';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = false;
opt_test.scale_grid = scales_investigate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Consensus MSTEP Cres
% Set the name of the current simulation
simu_name = 'cons_mstep_cores';
target = 'cons';
% Set the inputs
in_test = in;
opt_test = opt_t;
% Set up pipeline parameters
opt_test.folder_out = [path_test simu_name];
opt_test.region_growing.thre_size = 0;
% Flags
opt_test.target_type = target;
opt_test.flag_cores = true;
opt_test.scale_grid = scales_investigate;
% Generate the pipeline
meta_pipe = psom_merge_pipeline(meta_pipe,...
                                niak_pipeline_stability_surf(in_test,...
                                opt_test), [simu_name '_']);

%% Run the pipeline
psom_run_pipeline(meta_pipe, opt_meta);