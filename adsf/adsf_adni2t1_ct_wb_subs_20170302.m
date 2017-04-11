%% script to subtype on whole brain cortical thickness in just adni2

clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/';

files_in.data = [path_c 'adni2/adni2_civet_vertex_stack_r_scanner_20170326.mat'];
files_in.mask = [path_c 'mask_whole_brain.mat'];

nb_sbt = [2 3 4 5 6 7];

for ss = 1:length(nb_sbt)
    files_out = struct;
    opt.folder_out = strcat(path_c,'adni2/wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus');
    psom_mkdir(opt.folder_out);
    opt.nb_subtype = nb_sbt(ss);
    
    adsf_brick_subtyping(files_in,files_out,opt);
    
end

%% visualization of subtypes
clear all

nb_sbt = [2 3 4 5 6 7];

for ss = 1:length(nb_sbt)
    files_in = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat('/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/');
    opt.nb_subtype = nb_sbt(ss);
    
    adsf_brick_visu_ct_sub(files_in,files_out,opt);
end

%% weight extraction
clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/';

nb_sbt = [2 3 4 5 6 7];

for ss = 1:length(nb_sbt)

    files_in.data.wb = strcat(path_c,'adni2/adni2_civet_vertex_stack_r_scanner_20170326.mat');
    files_in.subtype.wb = strcat(path_c,'adni2/wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_c,'adni2/wb_ct_subtypes_scanner/wb_ct_sub_20170326_',num2str(nb_sbt(ss)),'clus/');
    
    adsf_brick_subtype_weight(files_in,files_out,opt);

end


