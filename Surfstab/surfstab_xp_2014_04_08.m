%% Meta Pipeline for running many simulations
%% Set Parameters
clear;
t = 100;
k = 16;
n = k^2;
target = 'cons';

path_simu = '/home/surchs/Projects/stability_abstract/out/simu/test_5/';
if ~psom_exist(path_simu)
    psom_mkdir(path_simu);
end

% 6 steps each
param_prec = 2;
range_fwhm = 1:6;
range_variance = 0.05:0.05:0.3;
scales_simulate = [4 16];
scales_investigate = 2:2:20;
queued = 2;

fwhm_id = 1;
variance_id = 1;

% Get the simulation parameters
fwhm = 2;
variance = 0.5;
fwhm_i = fix(fwhm);
fwhm_d = round(rem(fwhm,1) * 10^param_prec);
variance_i = fix(variance);
variance_d = round(rem(variance,1) * 10^param_prec);

% Set the name of the current simulation
simu_name = 'test';

% Set the simulation parameters
opt_s.type = 'checkerboard';
opt_s.t = t;
opt_s.n = n;
opt_s.nb_clusters = scales_simulate;
opt_s.fwhm = fwhm;
opt_s.variance = variance;

% Set up pipeline parameters
opt_p.folder_out = [path_simu simu_name];
opt_p.name_data = 'data';
opt_p.scale_grid = scales_investigate;
opt_p.scale_tar = scales_investigate;
opt_p.region_growing.thre_size = 0;
opt_p.stability_atom.nb_batch = 2;
opt_p.stability_vertex.nb_batch = 2;
% Sampling
opt_p.sampling.type = 'scenario';
opt_p.sampling.opt = opt_s;
% Flags
opt_p.target_type = target;
opt_p.consensus.scale_tar = [];
opt_p.flag_cores = true;
opt_p.flag_rand = false;
opt_p.flag_verbose = true;
opt_p.flag_test = false;
opt_p.psom.flag_pause = false;
% Psom
opt_p.psom.qsub_options = '-q sw -l nodes=1:ppn=1,walltime=00:50:00';
opt_p.psom.max_queued = queued;

% Save the current script for reference purposes
file_name = sprintf('%s_%s.m', date, simu_name);
script_path = [opt_p.folder_out '/' file_name];
if ~isdir(opt_p.folder_out)
    niak_mkdir(opt_p.folder_out);
end
orig_path = sprintf('%s.m', mfilename('fullpath'));
copyfile(orig_path, script_path);

% Generate the simulated dataset
[ref_tseries,opt_sx] = niak_simus_scenario(opt_s);
R_ref = niak_build_correlation(ref_tseries);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);

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

% Set Neighbourhood Mask
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

% Generate the reference partition
part_opt.thresh = scales_investigate;
part_out.part = niak_threshold_hierarchy(hier_ref, part_opt);
part_out.scale = scales_investigate;
file_part = [opt_p.folder_out filesep 'part.mat'];

% Set up the input file
in.data = file_simu;
in.neigh = file_neigh;
if strcmp(opt_p.target_type, 'manual')
    if exist(file_part, 'file') ~= 2
        save(file_part, '-struct', 'part_out');
    else
        warning('Reference partition file already exists. Leaving the old version!\n   %s',file_part);
    end
    in.part = file_part;
end

% Generate the pipeline
pipe = niak_pipeline_stability_surf(in,opt_p);

