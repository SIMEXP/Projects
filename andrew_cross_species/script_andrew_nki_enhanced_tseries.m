clear

%% Add quarantaine 
addpath(genpath('/home/bellecp1/quarantine/niak-2013-06-07'));

%% Folder names
path_preproc = '/home/bellecp1/database/nki_enhanced/fmri_preprocess/';
path_write = '/home/bellecp1/database/nki_enhanced/andrew_time_series/';

%% Grab preprocessing & templates
opt_g.min_nb_vol = 0;
opt_g.min_xcorr_func = -Inf;
opt_g.min_xcorr_anat = -Inf;
files = niak_grab_fmri_preprocess(path_preproc,opt_g);
file_template_mnc  = [path_write filesep 'template_andrew_r1.mnc.gz'];
file_template_res  = [path_write filesep 'template_andrew_r1_resample.mnc.gz'];
file_template_mask = [path_write filesep 'template_andrew_r1_masked.mnc.gz'];

%% Resample Andrew's mask in the correct space
pipeline = struct();
clear job_in job_out job_opt
job_in.source = file_template_mnc;
job_in.target = files.mask;
job_out = file_template_res;
job_opt.interpolation = 'nearest_neighbour';
pipeline = psom_add_job(pipeline,'resample_template','niak_brick_resample_vol',job_in,job_out,job_opt);

%% Combine Andrew's template with NIAK's functional mask
clear job_in job_out job_opt
job_in{1} = file_template_res;
job_in{2} = files.mask;
job_out = file_template_mask;
job_opt.operation = 'vol = vol_in{1}; vol(~vol_in{2}) = 0;';
pipeline = psom_add_job(pipeline,'mask_template','niak_brick_math_vol',job_in,job_out,job_opt);

%% Generate time series
list_subject = fieldnames(files.data);
for num_s = 1:length(list_subject)
    clear job_in job_out job_opt
    subject = list_subject{num_s};
    job_in.fmri = psom_files2cell(files.data.(subject));
    job_in.mask = file_template_mask;
    for num_r = 1:length(job_in.fmri)
        [path_f,name_f,ext_f] = niak_fileparts(job_in.fmri{num_r});
        job_out.tseries{num_r,1} = [path_write filesep 'tseries_' name_f '.mat'];
    end
    job_opt.flag_std = false;
    pipeline = psom_add_job(pipeline,['tseries_' subject],'niak_brick_tseries',job_in,job_out,job_opt);
end

opt_pipe.path_logs = [path_write filesep 'logs'];
opt_pipe.flag_pause = false;
psom_run_pipeline(pipeline,opt_pipe)
