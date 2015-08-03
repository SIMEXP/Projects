
%% admci extraction findings

clear all

%% add niak path
addpath(genpath('/sb/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))

%% input

path_results =  '/home/atam/database/adnet/results/glm30b_20141216_nii/';
path_scale =    {'sci35_scg35_scf33'};
path_contrast = {'ctrlvsmci'};
path_overlap = {'ctrlvsmci'}; % for % disc

data_contrast = {'ctrlvsmci'};
data_overlap = {'ctrlvsmci'};  % for % disc

data_seed     = {'22vmpfc','9dpfc','31sensmot','12mtl'};
data_cluster =   [22 9 31 12];
data_newcluster = [1 2 3 4];


%% Connectome ROIs

% single vol with reordered selected networks

[hdr,vol] = niak_read_vol(strcat(path_results,path_scale{1},'/networks/networks_sci35_scg35_scf33.nii.gz'));
vol2 = zeros(size(vol));

for k = 1:length(data_cluster)
    vol2(vol==data_cluster(k)) = data_newcluster(k);
end
hdr.file_name = strcat(path_results,path_scale{1},'/networks/glm30b_sc33_largesteffseeds.nii.gz');
niak_write_vol(hdr,vol2);


% write .csv for connectome analysis 

opt.labels_y = {'roi_basc'};
opt.labels_x = data_seed;
seeds(:,1) = data_newcluster;
niak_write_csv(strcat(path_results,path_scale{1},'/effseeds_sci130_scg117_scf111.csv'),seeds,opt)




%% GLM connectome extraction


for i = 1:length(path_scale)
    for k = 1:length(data_cluster)
        
% map d'un seul cluster (à partir de networks) avec valeur à 1
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
submask = zeros(size(mask));
cluster = data_cluster(k);
submask(mask==cluster) = 1;
hdr.file_name = strcat(path_results,'/',path_scale{i},'/networks/cluster_',data_seed{k},'_networks_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,submask);

    end
end
  


%% Thresholded effect maps
 
% FDR
 
 
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        for k = 1:length(data_cluster)
        
[hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_',path_overlap{j},'_',path_scale{i},'.nii.gz'));
[hdr,eff] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_overlap{j},'_',path_scale{i},'.nii.gz'));
cluster = data_cluster(k);
mask_fdr = fdr(:,:,:,cluster);
mask_eff = eff(:,:,:,cluster);
eff_new = zeros(size(mask_eff));
% eff_new(mask_fdr>0|mask_fdr<0) = mask_eff(mask_fdr>0|mask_fdr<0);
eff_new(mask_fdr>0) = mask_eff(mask_fdr>0);
eff_new(mask_fdr<0) = mask_eff(mask_fdr<0);
 
hdr.file_name = strcat(path_results,'/',path_scale{i},'/effects/effect_fdr_overlap_',path_contrast{j},'_',data_seed{k},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,eff_new);
 
        end
    end
end

%% effect abs max
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
[hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
mask_bin = mask>0;
effect_absmax = zeros(size(mask));
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            effect_absmax(mask==num_t) = max(abs(effect_tmp(mask_bin)));
        end
hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/max_abs_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,effect_absmax); 
    end
end



%% disc thresholded effect abs max
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        [hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
        [hdr,disc] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/perc_disc_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
        [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
        mask_bin = mask>0;
        %disc_bin = disc>0;
        effect_absmax = zeros(size(mask));
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            effect_absmax(mask==num_t) = max(abs(effect_tmp(mask_bin)));
        end
        effect_absmax(disc==0) = 0;
        hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/disc_max_abs_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
        niak_write_vol(hdr,effect_absmax);
    end
end



%% fdr thesholded effect abs max
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        [hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
        [hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
        [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
        
        effect_absmax = zeros(size(mask));       
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            fdr_tmp = fdr(:,:,:,num_t);
            effect_tmp(fdr_tmp==0)=0;
            effect_absmax(mask==num_t) = max(abs(effect_tmp(mask>0)));
        end
        hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_max_abs_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
        niak_write_vol(hdr,effect_absmax);
    end
end

%% effect mean
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
[hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
mask_bin = mask>0;
effect_mean = zeros(size(mask));
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            effect_mean(mask==num_t) = mean(effect_tmp(mask_bin));
        end
hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/mean_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,effect_mean); 
    end
end

%% effect sum of squares
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
[hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
mask_bin = mask>0;
effect_sumsqr = zeros(size(mask));
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            effect_sumsqr(mask==num_t) = sumsq(effect_tmp(mask_bin));  %%is this right?  I'm literally guessing from what I've read on google about matlab.
        end
hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/sumsqr_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,effect_sumsqr); 
    end
end

%% effect square root of average of sum of squares?
for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
[hdr,effect] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/effect_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
mask_bin = mask>0;
effect_sqrtavgsumsqr = zeros(size(mask));
        for num_t = 1:size(effect,4);
            effect_tmp = effect(:,:,:,num_t);
            effect_sqrtavgsumsqr(mask==num_t) = sqrt(sumsq(effect_tmp(mask_bin))/sum(mask_bin(:))); %% is this right?
        end
hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/sqrtavgsumsqr_effect_',path_contrast{j},'_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,effect_sqrtavgsumsqr); 
    end
end

% %% write .csv with minimal t values surviving FDR correction
% 
% opt.labels_y = data_contrast;
% opt.labels_x = data_seed;
% opt.precision = 2;
% niak_write_csv(strcat(path_results,'/',path_scale{i},'/fdr_values_min.csv'),data_values_min,opt)
% niak_write_csv(strcat(path_results,'/',path_scale{i},'/fdr_values_max.csv'),data_values_max,opt)
% 
% 
% %% t abs max
% 
% 
% for i = 1:length(path_scale)
%     for j = 1:length(path_contrast)
% 
% [hdr,ttest] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
% [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
% mask_bin = mask>0;
% ttest_absmax = zeros(size(mask));
%         for num_t = 1:size(ttest,4);
%             ttest_tmp = ttest(:,:,:,num_t);
%             ttest_absmax(mask==num_t) = max(abs(ttest_tmp(mask_bin)));
%         end
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/max_abs_ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,ttest_absmax);
% 
%     end
% end
% 
% 
% %% t positif et negatif
% 
% for i = 1:length(path_scale)
%     for j = 1:length(path_contrast)
% 
% [hdr,ttest] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
% [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
% mask_bin = mask>0;
% 
% ttest_max = zeros(size(mask));
%         for num_t = 1:size(ttest,4);
%             ttest_tmp_max = ttest(:,:,:,num_t);
%             ttest_max(mask==num_t) = max(ttest_tmp_max(mask_bin));
%         end
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/max_ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,ttest_max);
% 
% ttest_min = zeros(size(mask));
%         for num_t = 1:size(ttest,4);
%             ttest_tmp_min = ttest(:,:,:,num_t);
%             ttest_min(mask==num_t) = min(ttest_tmp_min(mask_bin));
%         end
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/min_ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,ttest_min);
% 
%     end
% end
% 
% 
% %% fdr maps positif et negatif
% 
% for i = 1:length(path_scale)
%     for j = 1:length(path_contrast)
% 
% [hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
% [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
% mask_bin = mask>0;
% 
% fdr_max = zeros(size(mask));
%         for num_t = 1:size(fdr,4);
%             fdr_tmp_max = fdr(:,:,:,num_t);
%             fdr_max(mask==num_t) = max(fdr_tmp_max(mask_bin));
%         end
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/max_fdr_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,fdr_max);
% 
% fdr_min = zeros(size(mask));
%         for num_t = 1:size(fdr,4);
%             fdr_tmp_min = fdr(:,:,:,num_t);
%             fdr_min(mask==num_t) = min(fdr_tmp_min(mask_bin));
%         end
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/min_fdr_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,fdr_min);
% 
%     end
% end


%% composite cluster map


[hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{1},'/networks/networks_',path_scale{1},'.nii.gz'));
submask = zeros(size(mask));
for k = 1:length(data_cluster)
    cluster = data_cluster(k);
    submask(mask==cluster) = 1;
end
hdr.file_name = strcat(path_results,'/',path_scale{1},'/networks/cluster_composite_networks_',path_scale{1},'.nii.gz');
niak_write_vol(hdr,submask);



% %% overlap fdr maps
% 
% 
% for i = 1:length(path_scale)
%     for k = 1:length(data_cluster)
%     
% [hdr,ctrlvsmci] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{1},'/fdr_',path_overlap{1},'_',path_scale{i},'.nii.gz'));
% [hdr,ctrlvsad] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{2},'/fdr_',path_overlap{2},'_',path_scale{i},'.nii.gz'));
% cluster = data_cluster(k);
% 
% ctrlvsmci_mask = ctrlvsmci(:,:,:,cluster);
% ctrlvsad_mask = ctrlvsad(:,:,:,cluster);
% 
% overlapmappos = zeros(size(ctrlvsmci(:,:,:,cluster)));
% overlapmapneg = zeros(size(ctrlvsmci(:,:,:,cluster)));
% 
% overlapmappos(ctrlvsmci_mask>0&ctrlvsad_mask>0) = 1; 
% overlapmapneg(ctrlvsmci_mask<0&ctrlvsad_mask<0) = -1; 
% 
% 
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlappos_',data_seed{k},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,overlapmappos);
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlapneg_',data_seed{k},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,overlapmapneg);
% 
%     end
% end
% 
% 
%% overlap min -max perc_disc map


for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        
[hdr,disc1] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{1},'/perc_disc_',path_overlap{1},'_',path_scale{i},'.nii.gz'));
[hdr,disc2] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{2},'/perc_disc_',path_overlap{2},'_',path_scale{i},'.nii.gz'));
[hdr,disc3] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{3},'/perc_disc_',path_overlap{3},'_',path_scale{i},'.nii.gz'));

overlapdiscmin = zeros(size(disc1));

overlapdiscmin_tmp = min(disc1,disc2);
overlapdiscmin = min(overlapdiscmin_tmp,disc3);


hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlapdiscmin_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,overlapdiscmin);

    end
end


for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        
[hdr,disc1] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{1},'/perc_disc_',path_overlap{1},'_',path_scale{i},'.nii.gz'));
[hdr,disc2] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{2},'/perc_disc_',path_overlap{2},'_',path_scale{i},'.nii.gz'));
[hdr,disc3] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{3},'/perc_disc_',path_overlap{3},'_',path_scale{i},'.nii.gz'));


overlapdiscmax = zeros(size(disc1));

overlapdiscmax_tmp = max(disc1,disc2);
overlapdiscmax = max(overlapdiscmax_tmp,disc3);

hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlapdiscmax_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,overlapdiscmax);

    end
end

%% overlap min -max max_abs_effect_ map


for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        
[hdr,disc1] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{1},'/max_abs_effect_',path_overlap{1},'_',path_scale{i},'.nii.gz'));
[hdr,disc2] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{2},'/max_abs_effect_',path_overlap{2},'_',path_scale{i},'.nii.gz'));
[hdr,disc3] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{3},'/max_abs_effect_',path_overlap{3},'_',path_scale{i},'.nii.gz'));

overlapdiscmin = zeros(size(disc1));

overlapdiscmin_tmp = min(disc1,disc2);
overlapdiscmin = min(overlapdiscmin_tmp,disc3);


hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlapabseffmin_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,overlapdiscmin);

    end
end


for i = 1:length(path_scale)
    for j = 1:length(path_contrast)
        
[hdr,disc1] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{1},'/max_abs_effect_',path_overlap{1},'_',path_scale{i},'.nii.gz'));
[hdr,disc2] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{2},'/max_abs_effect_',path_overlap{2},'_',path_scale{i},'.nii.gz'));
[hdr,disc3] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_overlap{3},'/max_abs_effect_',path_overlap{3},'_',path_scale{i},'.nii.gz'));


overlapdiscmax = zeros(size(disc1));

overlapdiscmax_tmp = max(disc1,disc2);
overlapdiscmax = max(overlapdiscmax_tmp,disc3);

hdr.file_name = strcat(path_results,'/',path_scale{i},'/overlap/overlapabseffmax_',path_scale{i},'.nii.gz');
niak_write_vol(hdr,overlapdiscmax);

    end
end

% for i = 1:length(path_scale)
%     for j = 1:length(path_contrast)
%         for k = 1:length(data_cluster)
%         
% 
% % ttest map avec d'un seul cluster dont la valeur est mise à 0
% [hdr,ttest] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/ttest_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
% [hdr,mask] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/networks/networks_',path_scale{i},'.nii.gz'));
% cluster = data_cluster(k);
% ttest_mask = ttest(:,:,:,cluster);
% ttest_mask(mask==cluster) = 0;
% hdr.file_name = strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/ttest_mask_',data_seed{k},'_',path_contrast{j},'_',path_scale{i},'.nii.gz');
% niak_write_vol(hdr,ttest_mask);


%% fdr threshold
% 
% [hdr,fdr] = niak_read_vol(strcat(path_results,'/',path_scale{i},'/',path_contrast{j},'/fdr_',path_contrast{j},'_',path_scale{i},'.nii.gz'));
% cluster = data_cluster(k);
% fdr_mask = abs(fdr(:,:,:,cluster));
% fdr_ok_min = fdr_mask;
% fdr_ok_max = fdr_mask;
% fdr_ok_min(fdr_mask==0) = 10;
% fdr_ok_min(fdr_mask==0) = 0;
% output_fdr_min = min(fdr_ok_min(:));    % probleme, ne fonctionne pas pour min!!!
% output_fdr_max = max(fdr_ok_max(:));
% data_values_min(k,j) = output_fdr_min;
% data_values_max(k,j) = output_fdr_max;
% 
%         end
%     end
% end

%% %%
% 
% 
% %% analysis
% 
% for n = 1:length(path_scale)
%     for m = 1:length(path_contrast)
%         
%         
%         % perc_disc
%         
%         data_values
%         
%         % abs_mean
%         [hdr,vol] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/ttest_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci160_scg144_scf143.nii.gz');
%         mask_bin = mask>0;
%         tabs = zeros(size(mask));
%         for num_t = 1:size(vol,4);
%             vol_tmp = vol(:,:,:,num_t);
%             tabs(mask==num_t) = mean(abs(vol_tmp(mask_bin)));
%         end
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/abs_ttest_mean_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz';
%         niak_write_vol(hdr,tabs);
% 
%         % abs_med
%         [hdr,vol] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/szVSctrl_tasks123/ttest_szVSctrl_tasks123_sci25_scg25_scf25.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/networks_sci25_scg25_scf25.nii.gz');
%         mask_bin = mask>0;
%         tabs = zeros(size(mask));
%         for num_t = 1:size(vol,4);
%             vol_tmp = vol(:,:,:,num_t);
%             tabs(mask==num_t) = median(abs(vol_tmp(mask_bin)));
%         end
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/szVSctrl_tasks123/median_abs.nii.gz';
%         niak_write_vol(hdr,tabs);
%         
%         % abs_perc90
%         [hdr,vol] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/szVSctrl_tasks123/ttest_szVSctrl_tasks123_sci25_scg25_scf25.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/networks_sci25_scg25_scf25.nii.gz');
%         mask_bin = mask>0;
%         tabs = zeros(size(mask));
%         for num_t = 1:size(vol,4);
%             vol_tmp = vol(:,:,:,num_t);
%             tabs(mask==num_t) = prctile(abs(vol_tmp(mask_bin)),90);
%         end
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci25_scg25_scf25/szVSctrl_tasks123/perc90_abs.nii.gz';
%         niak_write_vol(hdr,tabs);
%         
%         % abs_max
%         [hdr,vol] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/ttest_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci160_scg144_scf143.nii.gz');
%         mask_bin = mask>0;
%         tabs = zeros(size(mask));
%         for num_t = 1:size(vol,4);
%             vol_tmp = vol(:,:,:,num_t);
%             tabs(mask==num_t) = max(abs(vol_tmp(mask_bin)));
%         end
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/abs_ttest_max_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz';
%         niak_write_vol(hdr,tabs);
%         
%         % perc_disc
%         
%         [hdr,vol] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/perc_disc_szVSctrl_tasks123_sci25_scg25_scf25.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci25_scg25_scf25.nii.gz');
%         
%         
%         % template_icbm_sym_09_white.nii.gz
%         
%         
%         [hdr,template] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/template_icbm_sym_09_white.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci160_scg144_scf143.nii.gz');
%         template_seed = template;
%         template_seed(mask==16) = 96.44166;
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/template_s143_seed16_putpos.nii.gz';
%         niak_write_vol(hdr,template_seed);
%         
%         [hdr,ttest] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/ttest_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz');
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci160_scg144_scf143.nii.gz');
%         ttest_mask = ttest(:,:,:,60);
%         ttest_mask(mask==60) = 0;
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/szVSctrl_tasks123/ttest_mask_c16putpos_szVSctrl_tasks123_sci160_scg144_scf143.nii.gz.nii.gz';
%         niak_write_vol(hdr,ttest_mask);
%         
%         [hdr,mask] = niak_read_vol('/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/networks_sci160_scg144_scf143.nii.gz');
%         submask = zeros(size(mask));
%         submask(mask==60) = 1;
%         hdr.file_name = '/Users/pyeror/Projects/Szsex/results/glm_connectome_260912_nii/sci160_scg144_scf143/submask_c60pfcm_networks_sci160_scg144_scf143.nii.gz';
%         niak_write_vol(hdr,submask);
% 
% %%%
% 
% values_seed = [92,73,61,79];
% names_seed  = {'mPFC','aPut','pPut','amyg'};
% 
% path_results = '/Users/pyeror/Projects/Szsex/results/glm_connectome_010812_szsex_general_selection_nii/';
% path_scale = 'sci180_scg180_scf180';
% path_contrast = 'szVSctrl_tasks123';
% 
% 
% for n = 1:length(values_seed)
%  
% 
% [hdr,vol_networks] = niak_read_vol([path_results path_scale '/networks_' path_scale '.nii.gz']);
% vol_seed = zeros(size(vol_networks));
% vol_seed(vol_networks==values_seed(n)) = 1;
% hdr.file_name = [path_results path_scale '/' names_seed{n} '_seed' num2str(values_seed(n)) '_' path_scale '.nii.gz'];
% niak_write_vol(hdr,double(vol_seed));
% 
% end
% 
% 
% data_values(5,1) = [7] % 5eme contraste, 1ere echelle/1ere variable
% opt.labels_y = data.covariates_group_names;
% opt.labels_x = data.covariates_group_subs;
% opt.precision = 5;
% niak_write_csv(strcat(
% niak_write_csv(strcat(data.dir_output,data.name_csv_group,'.csv'),data_values,opt)