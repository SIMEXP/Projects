clear

%% This script shows how to extract the connectivity values for different contrasts and seeds in the ADNET analysis.

% this will write a csv for one seed of interest
clear all

%% Parameters
path_data = '/home/pbellec/database/adnet/adnet_main_results/';
list_seed = [10]; % select seed of interest
scale = 'sci35_scg35_scf33'; % select scale
list_contrast = { 'ctrlvsmci' , 'avg_ctrl' , 'avg_mci' }; % list the contrasts of interest
list_site = { 'adni2' , 'criugmmci' , 'adpd' , 'mnimci' }; % list of the sites.

for num_seed = 1:length(list_seed)
    seed = list_seed(num_seed);
    file_res = [path_data 'adnet_main_results_seed' sprintf('%i',seed) '.mat'];

    %% First read the networks and find a few significant seeds
    [hdr,netwk] = niak_read_vol([path_data 'glm30b_pooled_nii_' scale filesep 'networks_' scale '.nii.gz']);
    [hdr,tmap1] = niak_read_vol([path_data 'glm30b_pooled_nii_' scale filesep list_contrast{1} filesep 'fdr_' list_contrast{1} '_' scale '.nii.gz']);
    list_sig = unique(netwk((tmap1(:,:,:,seed)~=0))); % List of parcels with significant findings for the selected seed in the MCI-CNE contrast
    for num_sig = 1:length(list_sig)
        labels_sig{num_sig} = sprintf('%i',list_sig(num_sig));
    end

    %% Extract the info for each contrast
    tab = cell(length(list_contrast),length(list_site));
    for num_c = 1:length(list_contrast)
        for num_s = 1:length(list_site)
            contrast = list_contrast{num_c};
            site = list_site{num_s};
            file_glm = [path_data 'glm30b_' site '_nii_' scale filesep contrast filesep 'glm_' contrast '_' scale '.mat'];
            data = load(file_glm);
            y = data.model_group.y; % a subject x connections array
            list_subject{num_c,num_s} = data.model_group.labels_x;
            tab{num_c,num_s} = zeros([size(y,1) length(list_sig)]);
            for num_subj = 1:length(list_subject{num_c,num_s})
                % Extract the vectorized connectome
                conn_v = y(num_subj,:);
                % Convert into a square matrix
                conn = niak_lvec2mat(conn_v);
                tab{num_c,num_s}(num_subj,:) = conn(list_sig,seed);
            end
        end
    end

    save(file_res,'tab','list_site','list_contrast','list_subject','list_sig');
end

%% notes to do the plots
% data_cne = tab{2,1};
% data_mci = tab{3,1};
% clf
% for num_sig = 1:size(data_cne,2)
%     hold on
%     plot(num_sig-0.2+0.1*rand(size(data_cne,1),1),data_cne(:,num_sig),'.')
%    plot(num_sig+0.2+0.1*rand(size(data_mci,1),1),data_mci(:,num_sig),'.')
% end
