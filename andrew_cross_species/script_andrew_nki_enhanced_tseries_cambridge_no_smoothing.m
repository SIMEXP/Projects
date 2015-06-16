clear

%% Folder names
path_preproc = '/peuplier/database4/nki_enhanced/fmri_preprocess_no_smoothing/';
path_write = '/peuplier/database4/nki_enhanced/andrew_time_series_cambridge_no_smoothing/';
file_template_mnc  = ['/peuplier/database4/nki_enhanced/template_cambridge_basc_multiscale_mnc_sym/template_cambridge_basc_multiscale_sym_scale122_roi.mnc.gz'];

%% Grab preprocessing & templates
opt_g.min_nb_vol = 0;
opt_g.min_xcorr_func = -Inf;
opt_g.min_xcorr_anat = -Inf;
files = niak_grab_fmri_preprocess(path_preproc,opt_g);

%% Generate time series
list_subject = fieldnames(files.data);
pipeline = struct;
for num_s = 1:length(list_subject)
    clear job_in job_out job_opt
    subject = list_subject{num_s};
    job_in.fmri = psom_files2cell(files.data.(subject));
    job_in.mask = file_template_mnc;
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
