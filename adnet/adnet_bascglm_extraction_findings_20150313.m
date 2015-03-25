
%% adnet bascglm extraction findings 

clear all
%% add niak path
addpath(genpath('/sb/project/gsf-624-aa/quarantaine/niak-boss-0.12.18'))
%% input

data_results =  '/media/database3/adnet/results/glm30b_nii/';

data_scale_all = {'sci5_scg4_scf4','sci5_scg7_scf6','sci15_scg12_scf12','sci20_scg22_scf22','sci35_scg35_scf33','sci80_scg64_scf65','sci130_scg117_scf111','sci190_scg209_scf208'};

data_contrast = {'ctrlvsmci'};
data_overlap = {'ctrlvsmci'};


data_type = {'effect'};

data_seed = {'caudate'}; %14 17 2
data_cluster = [4 5 1 1 2 4 5 37];


%% single FDR, TTEST or EFFECT maps 


for tt = 1:length(data_type)
    for ss = 1:length(data_seed)
        for cc = 1:length(data_contrast)
            for sc = 1:length(data_scale_all)
                [hdr,net] = niak_read_vol(strcat(data_results,'/',data_scale_all{sc},'/networks/networks_',data_scale_all{sc},'.nii.gz'));
                mask = net>0;
                [hdr,con] = niak_read_vol(strcat(data_results,'/',data_scale_all{sc},'/',data_contrast{cc},'/',data_type{tt},'_',data_contrast{cc},'_',data_scale_all{sc},'.nii.gz'));
                cl = ss+(sc-1)*1; % *n avec n=length(data_seed)
                cluster = data_cluster(cl);
                con_new = con(:,:,:,cluster);
                hdr.file_name = strcat(data_results,'/effects/single_',data_type{tt},'_',data_contrast{cc},'_',data_seed{ss},'_',data_scale_all{sc},'.nii.gz');
                niak_write_vol(hdr,con_new);
            end
        end
    end
end


%% correlation coefficients 8 scales
% correlation of spatial effect maps

[hdr,net] = niak_read_vol(strcat(data_results,'/',data_scale_all{sc},'/networks/networks_',data_scale_all{sc},'.nii.gz'));
mask = net>0;

for cc = 1:length(data_contrast)
    for ss = 1:length(data_seed)
        eff = zeros([size(net) length(data_scale_all)]);
        for sc = 1:length(data_scale_all)
            [hdr,eff(:,:,:,sc)] = niak_read_vol(strcat(data_results,'/effects/single_effect_',data_contrast{cc},'_',data_seed{ss},'_',data_scale_all{sc},'.nii.gz'));
        end
        tseries = niak_vol2tseries(eff,mask);
        R = corr(tseries');        

        namemat = strcat(data_results,'/effects/corr_effects_0.3_',data_seed{ss},'.mat');
        save(namemat,'R')

        colormap jet
        imagesc(R,[0 1]);
        colorbar;
        axis square

        namefig = strcat(data_results,'/effects/corr_effects_0.3_',data_seed{ss},'.pdf');
        print(namefig,'-dpdf','-r600') 

    end
end






