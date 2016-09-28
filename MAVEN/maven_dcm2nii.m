%% script to convert maven database from dicom to mnc

clear
path_dcm = '/media/yassinebha/database24/MAVEN_06_2016/raw_dcm/';
path_mnc = '/media/yassinebha/database24/MAVEN_06_2016/raw_mnc/';
opt_pipe.path_logs = [path_mnc 'logs_conversion'];
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};

nb_subject = length(list_subject);
pipeline = struct();
for num_s = 1:nb_subject
    subject_folder = list_subject{num_s};
    subject_ID = subject_folder(1:(strfind(subject_folder,'_')(1))-1);
    subject_ID_tmp = subject_ID;
    subject_ID(strfind(subject_ID,'-')) = [];
    fprintf('Subject %s\n',subject_ID);
    path_read      = [path_dcm subject_folder filesep];        
    path_write     = [path_mnc subject_ID filesep];
    path_tmp       = [path_write 'tmp' filesep];
    
    % create folders
    niak_mkdir([path_write 'tmp/']);
    niak_mkdir([path_write 'func/']);
    niak_mkdir([path_write 'anat/']);
    
    % convert all to mnc in the tmp folder
    instr_dcm2mnc = ['dcm2mnc -dname '''' ' path_read '* ' path_tmp];
   
    % start jobs
    name_job = sprintf('%s',subject_ID);
    pipeline.(name_job).opt.instr_conv = instr_dcm2mnc;
    pipeline.(name_job).command = 'system(opt.instr_conv_final)';
end
opt_pipe.max_queued = 8;
psom_run_pipeline(pipeline,opt_pipe)