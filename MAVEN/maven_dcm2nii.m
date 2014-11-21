%% script to convert maven database from dicom to mnc

clear
path_dcm = '/media/database6/MAVEN/dicom/';
path_nii = '/media/database6/MAVEN/raw_nifti/';
opt_pipe.path_logs = [path_nii 'logs_conversion'];
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};

nb_subject = length(list_subject);
nb_subject = 1;
pipeline = struct();
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_read      = [path_dcm subject filesep];        
    path_write     = [path_nii subject filesep];
    path_tmp       = [path_nii subject filesep 'tmp' filesep];
    path_func_run1 = [path_tmp subject 'RSN1ep2*'];
    path_func_run2 = [path_tmp subject 'RSN2ep2*'];
    path_func_run3 = [path_tmp subject 'RSN3ep2*'];
    path_anat      = [path_tmp subject '*MPRAGEt1*'];
    
    name_job   = sprintf('%s',subject);
    pipeline.(name_job).files_in            = path_read;
    pipeline.(name_job).files_out.tmp       = path_tmp;
    pipeline.(name_job).files_out_tmp       = ['mkdir -p ' path_write 'tmp/']
    pipeline.(name_job).opt.instr_conv_nii  = ['dcm2nii -o ' path_tmp ' ' path_read '*'];
    pipeline.(name_job).opt.grab_func_run1  = ['mkdir -p ' path_write  'func/run1/ ; scp -r ' path_func_run1 ' ' path_write 'func/run1/'];
    pipeline.(name_job).opt.grab_func_run2  = ['mkdir -p ' path_write  'func/run2/ ; scp -r ' path_func_run2 ' ' path_write 'func/run2/'];
    pipeline.(name_job).opt.grab_func_run3  = ['mkdir -p ' path_write  'func/run3/ ; scp -r ' path_func_run3 ' ' path_write 'func/run3/'];
    pipeline.(name_job).opt.grab_anat_files = ['mkdir -p ' path_write  'anat/      ; scp -r ' path_anat ' ' path_write 'anat/'];
    pipeline.(name_job).command             = 'system(files_out.tmp) ;%system(opt.instr_conv_nii);%system(opt.grab_func_run1);system(opt.grab_func_run2);system(opt.grab_func_run3);system(opt.grab_anat_files); % niak_brick_nii2mnc([path_write "func/"],[path_write "func/"]); niak_brick_nii2mnc([path_write "anat/"],[path_write "anat/"]);';        
    pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
end
psom_run_pipeline(pipeline,opt_pipe)

