%% script to convert maven database from dicom to mnc and arrange them 
%% according to the bids format

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
    % convert all to nii in the tmp folder
    instr_dcm2mnc = ['dcm2mnc -dname %N ' path_read '* ' path_tmp];
    
    % copy func and anat to the right folder
    % run1
    run1_name = [subject_ID '_task-rest1_run-01_bold.mnc'];
    instr_cp_run1 = ['scp -r ' path_tmp lower(subject_folder) filesep lower(subject_folder) '*_4_mri.mnc ' path_write 'func/' run1_name ];
    
    % run2
    run2_name = [subject_ID '_task-rest2inscape_run-02_bold.mnc'];
    instr_cp_run2 = ['scp -r ' path_tmp lower(subject_folder) filesep lower(subject_folder) '*_5_mri.mnc ' path_write 'func/' run2_name ];
    
    % run3
    run3_name = [subject_ID '_task-rest3_run-03_bold.mnc'];
    instr_cp_run3 = ['scp -r ' path_tmp lower(subject_folder) filesep lower(subject_folder) '*_6_mri.mnc ' path_write 'func/' run3_name ];
    
    % anat
    anat_name = [subject_ID '_T1w.mnc'];
    instr_cp_anat = ['scp -r ' path_tmp lower(subject_folder) filesep lower(subject_folder) '*_9_mri.mnc ' path_write 'anat/' anat_name ];
    
    % Final instruction dcm2nii
    instr_final_dcm2mnc = [instr_dcm2mnc ';' instr_cp_run1 ';' instr_cp_run2 ';' instr_cp_run3 ';' instr_cp_anat];
    
    %start jobs
    name_job = sprintf('%s',subject_ID);
    pipeline.(name_job).opt.instr_conv_final = instr_final_dcm2mnc;
    pipeline.(name_job).command = 'system(opt.instr_conv_final)';
end
psom_run_pipeline(pipeline,opt_pipe)

