clear;
%% Wrapper for functional data
% Set the output path
in_path = '/home/sebastian/tmp/';
out_path = '/home/sebastian/tmp/func/';
if ~psom_exist(out_path)
    psom_mkdir(out_path);
end

job = 1;
meta_queued = 100;
pipe_queued = 10;
target = 'plugin';

% Set the stage for the individual subjects
subjects = {
            '0051491',...
            };
num_subs = length(subjects);

file_part = '';

% Meta-pipeline
meta_pipe = struct;
opt_meta = struct;

opt_meta.path_logs = [out_path 'logs'];
opt_meta.flag_test = true;
opt_meta.qsub_options = '-q sw -l nodes=1:ppn=1,walltime=01:00:00';
opt_meta.max_queued = meta_queued;
opt_meta.flag_pause = false;

for sub_id = 1:num_subs    
    % Get the subject name
    sub_name = subjects{sub_id};
    % Get the path to the subject file
    sub_file = niak_full_path([in_path filesep sprintf('fmri_%s_session_1_run1.nii.gz', sub_name)]);
    
    % Set up pipeline parameters
    opt_p.folder_out = niak_full_path([out_path filesep sub_name]);
    opt_p.name_data = 'data';
    opt_p.region_growing.thre_size = 0;
    opt_p.stability_atom.nb_batch = 10;
    opt_p.stability_vertex.nb_batch = 10;
    % Sampling
    opt_p.sampling.type = 'bootstrap';
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
    opt_p.psom.max_queued = pipe_queued;
    
    % Save the current script for reference purposes
    file_name = sprintf('%s_%s.m', date, sub_name);
    script_path = [opt_p.folder_out '/' file_name];
    if ~isdir(opt_p.folder_out)
        niak_mkdir(opt_p.folder_out);
    end
    orig_path = sprintf('%s.m', mfilename('fullpath'));
    copyfile(orig_path, script_path);
    
    % Set up the input file
    in.data = sub_file;
    if strcmp(opt_p.target_type, 'manual')
        in.part = file_part;
    end
    
    % Generate the pipeline
    pipe = niak_pipeline_stability_surf(in,opt_p);
    if job
        % Make a job out of the pipeline
        pipe_logs = [opt_p.folder_out filesep 'logs'];
        [pipe_job, pipe_clean] = psom_pipeline2job(pipe, pipe_logs);

        % Add the pipeline job to the meta pipeline
        name_pipe_job = sprintf('job_%s', sub_name);
        name_pipe_clean = sprintf('clean_%s', sub_name);
        meta_pipe.(name_pipe_job) = pipe_job;
        meta_pipe.(name_pipe_clean) = pipe_clean;
    else
        % Don't make a job out of it but just add the whole thing with a
        % prefix
        meta_pipe = psom_merge_pipeline(meta_pipe, pipe, sub_name);
        
    end
end

if ~opt_meta.flag_test
    % Run the meta pipeline
    psom_run_pipeline(meta_pipe, opt_meta);
end


