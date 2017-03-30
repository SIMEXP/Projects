%% script to test variables (diagnosis, amyloid...) on weights for whole brain cortical thickness in adni2
clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/';
files_in.model = '/Users/AngelaTam/Desktop/adsf/adni2_csv/adni2_t1_niak_model.csv';

nb_sbt = [2 3 4 5 6 7];
%vars = {'AV45','FDG','ADAS11','MMSE','MOCA','EcogPtTotal','EcogSPTotal'};
vars = {'diagnosis'};

for ss = 1:length(nb_sbt)

    files_in.weight = strcat(path_c,'wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/subtype_weights.mat');
    
    for vv = 1:length(vars)
        clear opt
        
        field = vars{vv};
        
        files_out = struct;
        opt.folder_out = strcat(path_c,'wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/glm/',field,'/');
        psom_mkdir(opt.folder_out);
        opt.scale = 1;
        opt.contrast.age = 0;
        opt.contrast.gender = 0;
        opt.contrast.mean_ct_wb = 0;
        opt.contrast.manufacturer = 0;
        
        %opt.contrast.diagnosis = 0;
        
        opt.contrast.(field) = 1;
        
        niak_brick_association_test(files_in,files_out,opt);
        opt.data_type = 'categorical';
        files_in.association = strcat(path_c,'wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/glm/',field,'/association_stats.mat');
        
        adsf_brick_visu_subtype_glm(files_in,files_out,opt);
        
    end
end