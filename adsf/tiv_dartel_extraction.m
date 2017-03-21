%% script to extract TIV from adni subjects in yasser's data

clear all

path_data = '/gs/project/gsf-624-aa/data/adni2_t1/dartel_gmd_yasser/';
path_model = '/gs/project/gsf-624-aa/data/adni2_t1/models/yasser_subjects_dartel.csv';

path_results = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/tissue_masks_first_session/';  

%% set up files_in structure
 
files_in.model = path_model;

%% filter out those with failed QC in model
[conf_model,list_subject,cat_names] = niak_read_csv(files_in.model);
qc_col = find(strcmp('dartel_qc',cat_names));
mask_qc = logical(conf_model(:,qc_col));
conf_model = conf_model(mask_qc,:);
list_subject = list_subject(mask_qc);

%% grab oldest processed T1s (c1,c2,c3) from each subject's folder & write brain mask

folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

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
            
            %% create the brain mask
            contrastt = 1;
            None = 1 - (GM + WM + CSF);
            indGM = find((GM > WM) & (GM > CSF) & (GM > None));
            indWM = find((WM > GM) & (WM > CSF) & (WM > None));
            indCSF = find((CSF > WM) & (CSF > GM) & (CSF > None));
            
            Mask_GM  = zeros(size(GM));
            Mask_WM  = zeros(size(GM));
            Mask_CSF = zeros(size(GM));
            Mask_GM(indGM) = 1;
            Mask_WM(indWM) = 1;
            Mask_CSF(indCSF) = 1;
            Mask_GM = imfill(Mask_GM,'holes');
            Mask_WM = imfill(Mask_WM,'holes');
            indGM = find(Mask_GM);
            indWM = find(Mask_WM);
            Mask_huecos = zeros(size(GM));
            Mask_huecos(unique([indGM; indWM])) = 1;
            Mask_WM_GM = Mask_huecos;
            Mask_Brain = Mask_WM_GM;
            Mask_Brain(indCSF) = 1;
            Mask_WM_GM = ((contrastt*WM + GM)/max(max(max((contrastt*WM + GM))))).*Mask_huecos;
            
            [path_m,name_m,ext_m] = niak_fileparts(GM_name);
            
            % write the mask
            hdr_gm.file_name = [path_results filesep sub_name '_mask_brain' ext_m];
            niak_write_vol(hdr_gm,Mask_Brain);
            
        end        
    end    
end

%% get TIV for each subject

clear all
path_data = '/gs/project/gsf-624-aa/data/adni2_t1/yasser_masks/tissue_masks_first_session/'; 

folds = dir(path_data);
folds = {folds.name};
folds = folds(~ismember(folds,{'.','..'}));

%% set up the csv
%%%%%%%%%%%%%%

for ss = 1:length(folds)
    % From folder name, grab subject ID
    sub_fold = folds{ss};
    tmp = strsplit(folds{ss},'_');
    % Store id of subject
    rid = tmp{1};
    % Set up subject id for fieldname
    tmp_vol = strcat(rid,'_mask_brain.nii.gz');
    % read volume
    [hdr,vol] = niak_read_vol(tmp_vol);
    % sum the voxels in the volume
    tiv = sum(vol(:));
    % write to csv
    %%%%%%%%%%%%%
end
    



