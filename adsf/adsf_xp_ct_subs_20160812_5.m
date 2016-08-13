%% prevent-ad cortical thickness subtypes

%% make the subtypes
clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_stack/';
path_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160812_5sub/';
psom_mkdir(path_out);

for ss = 1:9
    files_in.data = strcat(path_data, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.mask = strcat(path_data, 'mask_network', num2str(ss), '.mat');
    files_out = struct;
    opt.nb_subtype = 5;
    opt.folder_out = [path_out, 'net', num2str(ss)];
    psom_mkdir(opt.folder_out)
    
    adsf_brick_subtyping(files_in,files_out,opt);
end

%% make the maps
clear all

path_data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160812_5sub/';

for ss = 1:9
    files_in = strcat(path_data, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_data, 'net', num2str(ss), '/figures');
    psom_mkdir(opt.folder_out)
    opt.nb_subtype = 5;
    
    adsf_brick_visu_ct_sub(files_in,files_out,opt);
end

%% weight extraction

clear all
path_stack = '/Users/AngelaTam/Desktop/adsf/ct_stack/';
path_sub = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160812_5sub/';

for ss = 1:9
    files_in.data.net = strcat(path_stack, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.subtype.net = strcat(path_sub, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_sub, 'net', num2str(ss));
    
    adsf_brick_subtype_weight(files_in,files_out,opt);
end
