clear

%% Folder names
path_preproc = '/peuplier/database4/nki_enhanced/fmri_preprocess_no_smoothing/';
path_read  = '/peuplier/database4/nki_enhanced/andrew_time_series_cambridge_no_smoothing/';
path_write = '/peuplier/database4/nki_enhanced/andrew_time_series_cambridge_no_smoothing_gsc/';
psom_mkdir(path_write)

% Grab preprocessing 
opt_g.min_nb_vol = 0;
opt_g.min_xcorr_func = -Inf;
opt_g.min_xcorr_anat = -Inf;
files = niak_grab_fmri_preprocess(path_preproc,opt_g);

%% correct the global signal
list_subject = fieldnames(files.data);
for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    fmri = psom_files2cell(files.data.(subject));
    for num_r = 1:length(fmri)
        [path_f,name_f,ext_f] = niak_fileparts(fmri{num_r});
        fprintf('%s\n',name_f)
        file_read = [path_read filesep 'tseries_' name_f '.mat'];
        data = load(file_read);
        data_gsc = struct(); 
        data_gsc.time_frames = data.time_frames;
        file_write = [path_write filesep 'tseries_' name_f '_gsc.mat'];
        tseries = niak_normalize_tseries(data.tseries);
        gb_avg = mean(tseries,2);
        [beta,data_gsc.tseries] = niak_lse(tseries,gb_avg);
        save(file_write,'-struct','data_gsc');
    end
end
