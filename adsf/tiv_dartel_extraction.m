%% script to extract TIV from adni subjects in yasser's data

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/yasser_subjects_dartel.csv'; 
 
files_in.model = path_model;

%% filter out those with failed QC in model
[conf_model,list_subject,cat_names] = niak_read_csv(files_in.model);
qc_col = find(strcmp('dartel_qc',cat_names));
mask_qc = logical(conf_model(:,qc_col));
conf_model = conf_model(mask_qc,:);
list_subject = list_subject(mask_qc);

folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

%% set up the csv

labels = cell(length(folds)+1,2);
labels{1,1} = 'subject';
labels{1,2} = 'TIV';

csvname = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/yasser_dartel_tiv.csv';
fid = fopen(csvname,'w');
fprintf(fid, '%s, %s\n', labels{1,:});

%% grab oldest processed T1s (c1,c2,c3) from each subject's folder 
for ss = 1:length(folds)
    % From folder name, grab subject ID
    sub_fold = folds{ss};
    tmp = strsplit(folds{ss},'_');
    % Store RID of subject
    rid = tmp{3};
    % Set up subject id for fieldname
    sub_name = strcat('subject',rid);
    
    % Only grab the file if subject passed QC
    if any(ismember(list_subject,sub_name))
        % Identify the correct files for C1 (grey matter)
        gm_files = dir([path_data sub_fold filesep 'c1rl_T1_*']);
        gm_files = {gm_files.name};
        gm_files = gm_files(~ismember(gm_files,{'.','..'}));
        % If c1rl_T1_* exists, take the first session, and read volume
        if ~isempty(gm_files)
            gm_session = gm_files{1};
            GM_name = [path_data sub_fold filesep gm_session];
            [hdr_gm, GM] = niak_read_vol(GM_name);
        end
        % Identify the correct files for C2 (white matter)
        wm_files = dir([path_data sub_fold filesep 'c2rl_T1_*']);
        wm_files = {wm_files.name};
        wm_files = wm_files(~ismember(wm_files,{'.','..'}));
        % If c1rl_T1_* exists, take the first session, and read volume
        if ~isempty(wm_files)
            wm_session = wm_files{1};
            WM_name = [path_data sub_fold filesep wm_session];
            [hdr_wm, WM] = niak_read_vol(WM_name);
        end
        % Identify the correct files for C3 (CSF)
        csf_files = dir([path_data sub_fold filesep 'c3rl_T1_*']);
        csf_files = {csf_files.name};
        csf_files = csf_files(~ismember(csf_files,{'.','..'}));
        % If c1rl_T1_* exists, take the first session, and read volume
        if ~isempty(csf_files)
            csf_session = csf_files{1};
            CSF_name = [path_data sub_fold filesep csf_session];
            [hdr_csf, CSF] = niak_read_vol(CSF_name);
            
            %% sum the volumes to get TIV
            gm_vol = sum(GM(:));
            wm_vol = sum(WM(:));
            csf_vol = sum(CSF(:));
            tiv = sum(gm_vol+wm_vol+csf_vol);
            
            % write to csv
            labels{ss+1,1} = sub_name;
            labels{ss+1,2} = tiv;
            fprintf(fid, '%s, %f\n', labels{ss+1,1}, labels{ss+1,2});
        end        
    end    
end

fclose(fid)
    



