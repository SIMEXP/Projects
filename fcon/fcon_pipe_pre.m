function [pipeline,files_in,files_out,opt] = fcon_pipe_pre(files_in,files_out,opt)
% 
% Executes all individual jobs of the pre-preprocessing step of analisis one after the other keeping track of which is done and which isn't and inputs and outputs for all jobs. See PSOM Project for more information.
% 
% [pipeline] = fcon_pipe_pre(files_in,files_out,opt)
% 
% IN:
%   files_in:
%     Structure containing:
%       databases:
%         Databases to use.
%       path_databases:
%         Path to stored databases.
%       database:
%         Database to use in single database mode.
% 
%   files_out:
%     Structure containing:
%       path_logs:
%         Path where to save the log files.
% 
%   opt:
%     Structure containing:
%       flag_test:
%         Logical value to tell if pipeline is executed or not. 0 to execute, 1 to simply output pipeline. By default: 0.
%       opt_fmri:
%         Options for the fmri preprocess step.
%       opt_infos:
%         Options for the infos step.
%       opt_psom:
%         Options for psom when running the pipeline.
%       flag_merge:
%         Flag which tells the software to execute the pipeline one database at a time or all databases at the same time.
%       flag_single:
%         Flag when executing with only one database.
% 
% OUT:
%   pipeline:
%     Structure of the pipeline. See PSOM Project for more information.
%   files_in:
%     Structure with the files_in given and updated.
%   files_out:
%     Structure with the files_out given and updated.
%   opt:
%     Structure with the opt given and updated.
% 

%%Checking defaults
gb_name_structure = 'files_in';
gb_list_fields = {'databases','database','path_databases'};
gb_list_defaults = {[],'','/database/fcon_1000/'};
niak_set_defaults;

gb_name_structure = 'files_out';
gb_list_fields = {'path_logs'};
gb_list_defaults = {'/database/fcon_1000/logs/all/fmri/'};
niak_set_defaults;

gb_name_structure = 'opt';
gb_list_fields = {'flag_test','opt_infos','opt_fmri','opt_psom','restart','flag_merge','flag_single'};
gb_list_defaults = {0,[],[],[],[],1,0};
niak_set_defaults;

gb_name_structure = 'opt.opt_infos';
gb_list_fields = {'path_release_table','sep_char'};
gb_list_defaults = {'/database/fcon_1000/fcon_1000_ReleaseTable.csv',';'};
niak_set_defaults;

if ~exist(opt.opt_infos.path_release_table,'file')
    error(cat(2,'Could not find the release table file : ',opt.opt_infos.path_release_table));
end
if ~exist(files_in.path_databases,'dir')
    error(cat(2,'Could not find the databases : ',files_in.path_databases));
end

if(opt.flag_single)
    files_in2.path_databases = files_in.path_databases;
    files_in2.databases{1} = files_in.database;
    clear files_in;
    files_in = files_in2;
end

for num_d = 1:length(files_in.databases)
    path_database = [files_in.path_databases filesep 'raw' filesep files_in.databases{num_d} filesep];
    path_demog = [path_database files_in.databases{num_d} '_demographics.txt'];
    path_output = [path_database 'output' filesep];
    path_mnc = [files_in.path_databases filesep 'converted' filesep files_in.databases{num_d} filesep];
    path_preprocess = [files_in.path_databases 'preprocessed' filesep files_in.databases{num_d} filesep];
    path_pipelines = [files_in.path_databases 'pipelines' filesep];
    path_logs = [path_database 'logs' filesep];

    %%Checking for missing files or folders
    if ~exist(path_demog,'file')
	warning(cat(2,'Could not find the demographics file : ',path_demog));
	continue;
    end
    if ~exist(path_output,'dir')
	mkdir(path_output);
	warning(cat(2,'Output directory did not exist, created one : ',path_output));
    end
    if ~exist(path_preprocess,'dir')
	mkdir(path_preprocess);
	warning(cat(2,'Preprocess directory did not exist, created one : ',path_preprocess));
    end
    if ~exist(path_mnc,'dir')
	mkdir(path_mnc);
	warning(cat(2,'Convert directory did not exist, created one : ',path_mnc));
    end

    %%Read the demographics file
    pipeline.([databases{num_d} '_read']).command = '[subjects] = fcon_read_demog(files_in); save(''-v7'',files_out.subjects,''subjects'')';
    pipeline.([databases{num_d} '_read']).files_in = path_demog;
    pipeline.([databases{num_d} '_read']).files_out.subjects = [path_output 'subjects.mat'];

    %%Make a little table with the demographics
    pipeline.([databases{num_d} '_select']).command = 'load(files_in.subjects); fcon_select(subjects,opt)';
    pipeline.([databases{num_d} '_select']).files_in = pipeline.([databases{num_d} '_read']).files_out;
    pipeline.([databases{num_d} '_select']).opt.image_path = [path_output 'age_distribution.png'];
    pipeline.([databases{num_d} '_select']).opt.diary_path = [path_output 'age_distribution.txt'];
    pipeline.([databases{num_d} '_select']).opt.flag_nohist = 0;

    %%Convert nii files to mnc
    pipeline.([databases{num_d} '_convert']).command = '[files_in,files_out,opt] = niak_brick_nii2mnc(files_in,files_out,opt)';
    pipeline.([databases{num_d} '_convert']).files_in = [files_in.path_databases filesep 'raw' filesep files_in.databases{num_d}];
    pipeline.([databases{num_d} '_convert']).files_out = path_mnc;
    pipeline.([databases{num_d} '_convert']).opt.flag_zip = 1;

    %%Get the list of files to use in the preprocess
    pipeline.([databases{num_d} '_get_files']).command = 'load(files_in.subjects); [process_list,missing_list] = fcon_get_files(subjects,opt); save(''-v7'',files_out.process_list,''process_list''); save(''-v7'',files_out.missing_list,''missing_list'')';
    pipeline.([databases{num_d} '_get_files']).files_in.subjects = pipeline.([databases{num_d} '_read']).files_out.subjects;
    pipeline.([databases{num_d} '_get_files']).files_in.wait_for = pipeline.([databases{num_d} '_convert']).files_out;
    pipeline.([databases{num_d} '_get_files']).files_out.process_list = [path_output 'process_list.mat'];
    pipeline.([databases{num_d} '_get_files']).files_out.missing_list = [path_output 'missing_list.mat'];
    pipeline.([databases{num_d} '_get_files']).opt.path_database = path_mnc;
    pipeline.([databases{num_d} '_get_files']).opt.max_func = 1;

    %%Get the infos for the database
    pipeline.([databases{num_d} '_get_infos']).command = 'infos = fcon_get_infos(opt); save(''-v7'',files_out.infos,''infos'')';
    pipeline.([databases{num_d} '_get_infos']).files_out.infos = [path_output 'infos.mat'];
    pipeline.([databases{num_d} '_get_infos']).opt.database = files_in.databases{num_d};
    pipeline.([databases{num_d} '_get_infos']).opt.path_databases = [files_in.path_databases 'raw' filesep];
    pipeline.([databases{num_d} '_get_infos']).opt.path_release_table = opt.opt_infos.path_release_table;
    pipeline.([databases{num_d} '_get_infos']).opt.sep_char = opt.opt_infos.sep_char;

    %%Generate preprocessing pipeline to execute remotely
    pipeline.([databases{num_d} '_get_preprocess']).command = 'load(files_in.process_list); load(files_in.infos); pipeline = fcon_fmri_preprocess(process_list,infos,files_in.folder_out,opt); save(''-v7'',files_out.pipeline,''pipeline'')';
    pipeline.([databases{num_d} '_get_preprocess']).files_in.process_list = pipeline.([databases{num_d} '_get_files']).files_out.process_list;
    pipeline.([databases{num_d} '_get_preprocess']).files_in.infos = pipeline.([databases{num_d} '_get_infos']).files_out.infos;
    pipeline.([databases{num_d} '_get_preprocess']).files_in.folder_out = path_preprocess;
    pipeline.([databases{num_d} '_get_preprocess']).opt = opt_fmri;
    pipeline.([databases{num_d} '_get_preprocess']).files_out.pipeline = [path_pipelines files_in.databases{num_d} '_pipeline_fmri.mat'];
    
    if ~opt.flag_merge
        opt.opt_psom.path_logs = path_logs;
        opt.opt_psom.path_search = '';
        opt.opt_psom.restart = opt.restart;
	if(opt.flag_test)
	    return
	end
	psom_run_pipeline(pipeline,opt.opt_psom);
	pipeline = struct;
    end
end
if opt.flag_merge
        opt.opt_psom.path_logs = files_out.path_logs;
        opt.opt_psom.path_search = '';
        opt.opt_psom.restart = opt.restart;
    if(opt.flag_test)
        return
    end
    psom_run_pipeline(pipeline,opt.opt_psom);
end