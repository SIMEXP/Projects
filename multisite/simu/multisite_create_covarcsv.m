%% Graber
addpath(genpath('/usr/local/niak/niak-boss-0.12.13'));

output_mat = '/data/cisl/cdansereau/multisite/demographic_1000fcon.csv';

%%%%%%%%%%%%
opt_g.min_nb_vol = 50;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
opt_g.filter.session = {'session1'}; % Just grab session 1
%opt_g.filter.run = {'rest'}; % Just grab the "rest" run

%opt_g.exclude_subject = {'SB_30013','SB_30026','SB_30035'};

tab = [];
lx = [];
ly = [];
tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Baltimore/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
for idx=1:size(names,1)
    valid_idx = ismember(lxx,[names{idx} '_session1_rest']);
    lx{idx} = names{idx};
    tab(idx,:) = [tab_fd(valid_idx,4),1];
end


tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Berlin/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),2];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Cambridge/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),3];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Newark/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),4];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/NewYork_b/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),5];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Oxford/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),6];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/Queensland/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),7];
    k=k+1;
end

tmp_path = '/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/SaintLouis/fmri_preprocess_05scrubb';
files_in_tmp = niak_grab_fmri_preprocess(tmp_path,opt_g); % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
names = fieldnames(files_in_tmp.fmri);
[tab_fd,lxx,lyy]=niak_read_csv([tmp_path '/quality_control/group_motion/qc_scrubbing_group.csv']);
k=1;
for idx=size(tab,1)+1:size(tab,1)+size(names,1)
    valid_idx = ismember(lxx,[names{k} '_session1_rest']);
    lx{idx} = names{k};
    tab(idx,:) = [tab_fd(valid_idx,4),8];
    k=k+1;
end


opt_csv.labels_x = lx;
opt_csv.labels_y = {'FD','multisite'};
niak_write_csv(output_mat,tab,opt_csv);











