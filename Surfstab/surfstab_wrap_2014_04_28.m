%% Wrapper for functional data
clear;

% Outline
% 1) Get the mask and the func files
% 2) Use niak_brick_tseries to get the tseries from the files
% 3) Use niak_brick_neighbour to build a neighbourhood from a mask
% 4) Store the timeseries in a mat. Store the neighbourhood in a mat
% 5) Run the files through our pipeline.

i_path = '/data1/Abide/Stanford/';
o_path = '/data1/Abide/Out/Test/kmeans_gobbel/';
m_path = '/data1/Abide/Out/Test/';

% Make sure the paths are good paths
in_path = niak_full_path(i_path);
out_path = niak_full_path(o_path);
mask_path = niak_full_path(m_path);

% Make sure the base output directory exists
if ~psom_exist(out_path)
    psom_mkdir(out_path);
end

% Define the brain mask 
mask_name = 'mask.nii';
mask_file = [mask_path mask_name];

% Define the search pattern for the functional file and for the subject ID
data_pattern = 'fmri_\d*_session_1_run1.nii';
sub_pattern = '\d*';

% Set up the main pipeline
main_pipe = struct;

files = dir(in_path)';
for file = files
    match = regexp(file.name, data_pattern, 'match');
    if ~isempty(match)
        % We have a match - find the subject name
        sub_match = regexp(file.name, sub_pattern, 'match');
        s_name = sub_match{1};
        s_file = [niak_full_path(in_path) file.name];
        % Define the subject folder
        sub_dir = niak_full_path([out_path s_name]);
        if ~psom_exist(sub_dir)
            psom_mkdir(sub_dir);
        end
        % Generate a preprocessing pipeline for the initial files
        pre_pipe = struct;
        pre_dict = niak_full_path([sub_dir 'pre']);
        
        
        % Use the information to create the pipeline for this subject
        in_ts.fmri = {s_file};
        in_ts.mask = mask_file;
        out_ts.tseries = {[sub_dir 'tseries.mat']};
        opt_ts.flag_all = true;
        pre_pipe = psom_add_job(pre_pipe, 'tseries', 'niak_brick_tseries',...
                              in_ts, out_ts, opt_ts);
        
        % Run the neighbour brick
        in_neigh = mask_file;
        out_neigh = [sub_dir 'neigh.mat'];
        opt_neigh = struct;
        pre_pipe = psom_add_job(pre_pipe, 'neighbour', 'niak_brick_neighbour',...
                              in_neigh, out_neigh, opt_neigh);

        % Bring things into the big pipeline
        in.data = pre_pipe.tseries.files_out;
        in.neigh = pre_pipe.neighbour.files_out;
        opt.name_data = 'tseries_1';
        opt.name_neigh = 'neig';
        opt.scale = [4 16 32];

        % Set up pipeline parameters
        opt.folder_out = sub_dir;
        opt.region_growing.thre_size = 100;
        opt.stability_atom.nb_batch = 2;
        opt.stability_vertex.nb_batch = 2;
        opt.stability_vertex.clustering.type = 'kmeans';
        % Sampling
        opt.sampling.type = 'bootstrap';
        % Flags
        opt.target_type = 'plugin';
        opt.consensus.scale_target = [4 8 16];
        opt.flag_cores = false;
        opt.flag_rand = false;
        opt.flag_verbose = true;
        opt.flag_test = true;
        opt.psom.flag_pause = true;
        % Generate the pipeline
        proc_pipe = niak_pipeline_stability_surf(in, opt);
        
        % Make a subject pipeline
        sub_pipe = struct;
        % Merge the other pipelines to the subject pipeline
        sub_pipe = psom_merge_pipeline(sub_pipe, pre_pipe, 'pre_');
        sub_pipe = psom_merge_pipeline(sub_pipe, proc_pipe, 'proc_');

    else
        continue
    end
    % Merge the subject pipeline with the main pipeline
    main_pipe = psom_merge_pipeline(main_pipe, sub_pipe, ['sub_' s_name '_']);
end

opt_main.path_logs = [out_path 'logs'];

psom_run_pipeline(main_pipe, opt_main);

fprintf('EOF\n');