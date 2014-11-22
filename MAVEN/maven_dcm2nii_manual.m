%% script to convert maven database from dicom to mnc

clear
path_dcm = '/media/database6/MAVEN/dicom/';
path_nii = '/media/database6/MAVEN/raw_nifti/';
opt_pipe.path_logs = [path_nii 'logs_conversion'];
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};

nb_subject = length(list_subject);
nb_subject = 1;
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_read      = [path_dcm subject filesep];        
    path_write     = [path_nii subject filesep];
    path_tmp       = [path_nii subject filesep 'tmp' filesep];
    path_func_run1 = [path_tmp filesep 'RSN1ep2*'];
    path_func_run2 = [path_tmp filesep 'RSN2ep2*'];
    path_func_run3 = [path_tmp filesep 'RSN3ep2*'];
    path_anat      = [path_tmp filesep '*MPRAGEt1*'];
    % create tmp folder
    system(['mkdir -p ' path_write 'tmp/']);
    % convert all to nii in the tmp folder
    system(['dcm2nii -o ' path_tmp ' ' path_read '*']);
    % create func path
    % run1
    system(['mkdir -p ' path_write  'func/run1/ ; scp -r ' path_func_run1 ' ' path_write 'func/run1/']);
    % run2
    system(['mkdir -p ' path_write  'func/run2/ ; scp -r ' path_func_run2 ' ' path_write 'func/run2/']);
    % run3
    system(['mkdir -p ' path_write  'func/run3/ ; scp -r ' path_func_run3 ' ' path_write 'func/run3/']);
    % create anat path
    system(['mkdir -p ' path_write  'anat/      ; scp -r ' path_anat ' ' path_write 'anat/']);
    niak_brick_nii2mnc([path_write "func/"],[path_write "func/"]); niak_brick_nii2mnc([path_write "anat/"],[path_write "anat/"]);';        
end
psom_run_pipeline(pipeline,opt_pipe)

