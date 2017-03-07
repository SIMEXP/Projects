%% script to test variables (diagnosis, amyloid...) on weights for whole brain cortical thickness in adni2
clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/';
files_in.model = '/Users/AngelaTam/Desktop/adsf/adni2_csv/adni2_t1_niak_model.csv';

nb_sbt = [2 3 4 5 6 7];
%vars = {'AV45','FDG','ADAS11','MMSE','MOCA','EcogPtTotal','EcogSPTotal'};
vars = {'diagnosis'};

for ss = 1:length(nb_sbt)

    files_in.weight = strcat(path_c,'wb_ct_subtypes_20170301_',num2str(nb_sbt(ss)),'clus/subtype_weights.mat');
    
    for vv = 1:length(vars)
        clear opt
        
        field = vars{vv};
        
        files_out = struct;
        opt.folder_out = strcat(path_c,'wb_ct_subtypes_20170301_',num2str(nb_sbt(ss)),'clus/glm_nosite/',field,'/');
        psom_mkdir(opt.folder_out);
        opt.scale = 1;
        opt.contrast.age = 0;
        opt.contrast.gender = 0;
        opt.contrast.mean_ct_wb = 0;
%         opt.contrast.site2 = 0;
%         opt.contrast.site6 = 0;
%         opt.contrast.site9 = 0;
%         opt.contrast.site11 = 0;
%         opt.contrast.site12 = 0;
%         opt.contrast.site13 = 0;
%         opt.contrast.site14 = 0;
%         opt.contrast.site18 = 0;
%         opt.contrast.site19 = 0;
%         opt.contrast.site22 = 0;
%         opt.contrast.site23 = 0;
%         opt.contrast.site24 = 0;
%         opt.contrast.site31 = 0;
%         opt.contrast.site32 = 0;
%         opt.contrast.site35 = 0;
%         opt.contrast.site36 = 0;
%         opt.contrast.site37 = 0;
%         opt.contrast.site41 = 0;
%         opt.contrast.site53 = 0;
%         opt.contrast.site67 = 0;
%         opt.contrast.site68 = 0;
%         opt.contrast.site72 = 0;
%         opt.contrast.site73 = 0;
%         opt.contrast.site82 = 0;
%         opt.contrast.site99 = 0;
%         opt.contrast.site100 = 0;
%         opt.contrast.site116 = 0;
%         opt.contrast.site123 = 0;
%         opt.contrast.site128 = 0;
%         opt.contrast.site130 = 0;
%         opt.contrast.site135 = 0;
%         opt.contrast.site136 = 0;
%         opt.contrast.site137 = 0;
%         opt.contrast.site141 = 0;
%         opt.contrast.site153 = 0;
%         opt.contrast.site941 = 0;
        
        %opt.contrast.diagnosis = 0;
        
        opt.contrast.(field) = 1;
        
        niak_brick_association_test(files_in,files_out,opt);
        opt.data_type = 'categorical';
        files_in.association = strcat(path_c,'wb_ct_subtypes_20170301_',num2str(nb_sbt(ss)),'clus/glm_nosite/',field,'/association_stats.mat');
        
        adsf_brick_visu_subtype_glm(files_in,files_out,opt);
        
    end
end