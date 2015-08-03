clear
%files = niak_grab_fmri_preprocess('/home/pbellec/database/aging/fmri_preprocess/');
files = niak_grab_fmri_preprocess('/media/database3/icbm/fmri_preprocess_phildi_09_2012/');
path_write = '/home/pbellec/database/for_andrew';
file_template = [path_write filesep 'template_andrew_r1.nii.gz'];
file_template_mnc = [path_write filesep 'template_andrew_r1.mnc.gz'];
file_mask_func = [path_write filesep 'mask_func.mnc.gz'];
file_mask = [path_write filesep 'template_andrew_r1_masked.mnc.gz'];
psom_mkdir(path_write)
list_subject = fieldnames(files.data);

%% Generate a target
job_in.source = file_template_mnc;
job_in.target = files.mask;
job_out = file_mask;
job_opt.interpolation = 'nearest_neighbour';
niak_brick_resample_vol(job_in,job_out,job_opt);
[hdr,mask] = niak_read_vol(job_out);
[hdr,mask_brain] = niak_read_vol(files.mask);
mask(~mask_brain) = 0;
hdr.file_name = job_out;
niak_write_vol(hdr,mask);

%% Generate time series
pipeline = struct();
for num_s = 1:length(list_subject)
    clear job_in job_out job_opt
    subject = list_subject{num_s};
    job_in.fmri = files.data.(subject);
    job_in.mask = file_mask;
    for num_r = 1:length(files.data.(subject))
        job_out.tseries{num_r,1} = [path_write filesep 'tseries_' subject '_run' int2str(num_r) '.mat'];
    end
    job_opt.flag_std = false;
    pipeline = psom_add_job(pipeline,['tseries_' subject],'niak_brick_tseries',job_in,job_out,job_opt);
end

opt_pipe.path_logs = [path_write filesep 'logs'];

