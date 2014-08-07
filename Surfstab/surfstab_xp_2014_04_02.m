%% Meta Pipeline for running many simulations
%% Set Parameters
t = 100;
k = 16;
n = k^2;
target = 'manual';

path_simu = sprintf('/home/surchs/Project/surfstab/local/simus/three/%s/',target);
if ~psom_exist(path_simu)
    psom_mkdir(path_simu);
end

% 6 steps each
param_prec = 2;
range_fwhm = 1:6;
range_variance = 0.05:0.05:0.3;
scales_simulate = [4 16];
scales_investigate = 2:2:20;
queued = 6;

% Generate the reference dataset
opt_ref.type = 'checkerboard';
opt_ref.t = t;
opt_ref.n = n;
opt_ref.nb_clusters = scales_simulate;
opt_ref.fwhm = 1;
opt_ref.variance = 1;
[tseries_ref,opt_sx] = niak_simus_scenario(opt_ref);
R_ref = niak_build_correlation(tseries_ref);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);

% Meta-pipeline
meta_pipe = struct;
opt_meta = struct;

opt_meta.path_logs = [path_simu 'logs'];
opt_meta.flag_test = false;
opt_meta.qsub_options = '-q sw -l nodes=1:ppn=1,walltime=01:00:00';
opt_meta.max_queued = queued;
opt_meta.flag_pause = false;

for fwhm_id = 1:length(range_fwhm)
    for variance_id = 1:length(range_variance)

        % Get the simulation parameters
        fwhm = range_fwhm(fwhm_id);
        variance = range_variance(variance_id);
        fwhm_i = fix(fwhm);
        fwhm_d = round(rem(fwhm,1) * 10^param_prec);
        variance_i = fix(variance);
        variance_d = round(rem(variance,1) * 10^param_prec);
        
        % Set the name of the current simulation
        simu_name = sprintf('simu_var_%d_%d_fwhm_%d_%d_%s',variance_i, variance_d, fwhm_i, fwhm_d, target);

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
        opt_p.scale = scales_investigate;
        opt_p.region_growing.thre_size = 0;
        opt_p.stability_atom.nb_batch = 10;
        opt_p.stability_vertex.nb_batch = 10;
        % Sampling
        opt_p.sampling.type = 'scenario';
        opt_p.sampling.opt = opt_s;
        % Flags
        opt_p.target_type = target;
        opt_p.consensus.scale_target = [4 8 16];
	    opt_p.flag_cores = true;
        opt_p.flag_rand = false;
        opt_p.flag_verbose = true;
        opt_p.flag_test = true;
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
        [tseries,opt_sx] = niak_simus_scenario(opt_s);
        R = niak_build_correlation(tseries);
        hier = niak_hierarchical_clustering(R);
        order = niak_hier2order(hier);
        
        simu_out = struct;
        simu_out.data = tseries;
        simu_out.order = order;
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
        part_out.order = order_ref;
        part_out.hier = hier_ref;
        file_part = [opt_p.folder_out filesep 'part.mat'];
        if exist(file_part, 'file') ~= 2
            save(file_part, '-struct', 'part_out');
        else
            warning('Reference partition file already exists. Leaving the old version!\n   %s',file_part);
        end

        % Set up the input file
        in.data = file_simu;
        in.neigh = file_neigh;
        if strcmp(opt_p.target_type, 'manual')
            in.part = file_part;
        end

        % Generate the pipeline
        pipe = niak_pipeline_stability_surf(in,opt_p);
        % Make a job out of the pipeline
        pipe_logs = [opt_p.folder_out filesep 'logs'];
        [pipe_job, pipe_clean] = psom_pipeline2job(pipe, pipe_logs);

        % Add the pipeline job to the meta pipeline
        name_pipe_job = sprintf('job_%s', simu_name);
        name_pipe_clean = sprintf('clean_%s', simu_name);
        meta_pipe.(name_pipe_job) = pipe_job;
        meta_pipe.(name_pipe_clean) = pipe_clean;
    end
end

if ~opt_meta.flag_test
    % Run the meta pipeline
    psom_run_pipeline(meta_pipe, opt_meta);
end


