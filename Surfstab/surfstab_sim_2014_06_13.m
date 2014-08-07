%% Meta Pipeline for running many simulations
clear;

path_simu = '/home/surchs/Project/surfstab/local/test/';
if ~psom_exist(path_simu)
    psom_mkdir(path_simu);
end

%% Set Parameters
t = 100;
k = 16;
n = k^2;

% 6 steps each
scales_simulate = [4 16];
scales_investigate = 2:2:20;

% Set the simulation parameters
opt_s.type = 'checkerboard';
opt_s.t = t;
opt_s.n = n;
opt_s.nb_clusters = scales_simulate;
opt_s.fwhm = 2;
opt_s.variance = 0.1;

queued = 6;

% Run the reference simulation
[ref_tseries, opt_sx] = niak_simus_scenario(opt_s);
R_ref = niak_build_correlation(ref_tseries);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);

% Pipeline options
opt_p.name_data = 'data';
opt_p.scale = scales_investigate;
opt_p.region_growing.thre_size = 0;
opt_p.stability_atom.nb_batch = 10;
opt_p.stability_vertex.nb_batch = 10;
% Sampling
opt_p.sampling.type = 'scenario';
opt_p.sampling.opt = opt_s;
% Flags
opt_p.type_target = 'cons';
opt_p.consensus.scale_target = [3 8];
opt_p.flag_cores = true;
opt_p.flag_rand = false;
opt_p.flag_verbose = true;
opt_p.flag_test = false;
opt_p.psom.flag_pause = false;
% Psom
opt_p.psom.qsub_options = '-q sw -l nodes=1:ppn=1,walltime=00:50:00';
opt_p.psom.max_queued = queued;
% Genarte simu name
simu_name = sprintf('simu_%0d_%0d_%s', opt_s.fwhm, opt_s.variance, opt_p.type_target);
% Set up pipeline parameters
opt_p.folder_out = [path_simu simu_name];

% Save the current script for reference purposes
file_name = sprintf('%s_%s.m', date, simu_name);
script_path = [opt_p.folder_out filesep file_name];
if ~isdir(opt_p.folder_out)
    niak_mkdir(opt_p.folder_out);
end
orig_path = sprintf('%s.m', mfilename('fullpath'));
copyfile(orig_path, script_path);

% Save neighbourhood mask
mask = true(k);
neigh = niak_build_neighbour(mask, 6);
mask_out = struct;
mask_out.neigh = neigh;
file_neigh = [opt_p.folder_out filesep 'neigh.mat'];
% See if the file already exists - useful for rerunning
if exist(file_neigh, 'file') ~= 2
    save(file_neigh, '-struct', 'mask_out');
else
    warning('Neighbourhood file already exists. Leaving the old version!\n   %s',file_neigh);
end

% Save simulated data
simu_out = struct;
simu_out.data = ref_tseries;
simu_out.order = order_ref;
data_name = sprintf('%s.mat', simu_name);
file_simu = [opt_p.folder_out filesep data_name];
% See if the file already exists - useful for rerunning
if exist(file_simu, 'file') ~= 2
    save(file_simu, '-struct', 'simu_out');
else
    warning('Data file already exists. Leaving the old version!\n    %s',file_simu);
end

% Make partition

% Set the simulation parameters
opt_s.fwhm = 1;
opt_s.variance = 1;

% Run the reference simulation
[part_tseries, opt_sx] = niak_simus_scenario(opt_s);
R_part = niak_build_correlation(part_tseries);
hier_part = niak_hierarchical_clustering(R_part);
order_part = niak_hier2order(hier_part);

% Save partition
opt_part.thresh = scales_simulate;
part_out.part = niak_threshold_hierarchy(hier_part, opt_part);
part_out.scale = scales_investigate;
part_name = 'part.mat';
file_part = [opt_p.folder_out filesep part_name];
% See if the file already exists
if exist(file_part, 'file') ~= 2
    save(file_part, '-struct', 'part_out');
else
    warning('Data file already exists. Leaving the old version!\n    %s',file_part);
end


% Set up the input file
in.data = file_simu;
in.neigh = file_neigh;
if strcmp(opt_p.type_target, 'manual')
    in.part = file_part;
end

% Generate the pipeline
pipe = niak_pipeline_stability_surf(in,opt_p);