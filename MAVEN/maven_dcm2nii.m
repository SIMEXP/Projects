%% script to convert maven database from dicom to mnc

clear
path_dcm = '/media/database6/MAVEN/dicom/';
path_nii = '/media/database6/MAVEN/dicom/raw_nifti/';
opt_pipe.path_logs = [path_nii 'logs_conversion'];
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};

nb_subject = length(list_subject);
%nb_subject = 2;
pipeline = struct();
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_read  = [path_dcm subject filesep];        
    path_write = [path_nii subject filesep  filesep];
    path_tmp   = [path_nii subject filesep 'tmp' filesep];
    name_job   = sprintf('%s',subject);
    pipeline.(name_job).files_in           = path_read;
    pipeline.(name_job).files_out.tmp      = path_tmp;
    pipeline.(name_job).files_out.func.run1 = [path_tmp subject 'RSN1ep2*'];
    pipeline.(name_job).files_out.func.run2 = [path_tmp subject 'RSN2ep2*'];
    pipeline.(name_job).files_out.func.run3 = [path_tmp subject 'RSN3ep2*'];
    pipeline.(name_job).files_out.anat      = [path_tmp subject '*MPRAGEt1*'];
    pipeline.(name_job).opt.instr_conv_nii = ['dcm2nii -o' path_tmp path_read filesep subject '*'];
    pipeline.(name_job).opt.instr_conv_mnc = ['dcm2nii ' path_tmp ' -f nifti -n -u –fnformat=-PatientId+PatientName+SequenceName ' path_read];
    pipeline.(name_job).command            = 'system(opt.instr_conv_nii); twi_mosaic2vol(files_out.tmp,files_out.func,files_out.anat);';        
    pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
end
psom_run_pipeline(pipeline,opt_pipe)

