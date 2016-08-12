%% prevent-ad cortical thickness subtypes

clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_stack/';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160812/';
psom_mkdir(path_out);

for ss = 1:9
    files_in.data = strcat(path_data, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.mask = strcat(path_data, 'mask_network', num2str(ss), '.mat');
    files_out = struct;
    opt.nb_subtype = 3;
    opt.folder_out = [path_out, 'net', num2str(ss)];
    psom_mkdir(opt.folder_out)
    
    adsf_brick_subtyping(files_in,files_out,opt);
end


clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160812/';

for ss = 1:9
    files_in = strcat(path_data, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_data, 'net', num2str(ss), '/figures');
    psom_mkdir(opt.folder_out)
    opt.nb_subtype = 3;
    
    adsf_brick_visu_ct_sub(files_in,files_out,opt);
end