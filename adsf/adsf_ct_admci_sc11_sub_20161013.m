%% subtyping sc11 basc ct admci networks on admci sample

%% make the subtypes
clear all

path_data = '/home/angela/Desktop/adsf/ct_subtypes/admci/basc_sc11_stacks/regress_agesexmeanct/';
path_out = '/home/angela/Desktop/adsf/ct_subtypes/admci/ct_sc11_sub_20161013/';
psom_mkdir(path_out);

net = [1 2 3 6];

for nn = 1:4
    ss = net(nn)
    files_in.data = strcat(path_data, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.mask = strcat(path_data, 'mask_network', num2str(ss), '.mat');
    files_out = struct;
    opt.nb_subtype = 4;
    opt.folder_out = [path_out, 'net', num2str(ss)];
    psom_mkdir(opt.folder_out)
    
    adsf_brick_subtyping(files_in,files_out,opt);
    clear files_in
end

%% make the maps
clear all

path_data = '/home/angela/Desktop/adsf/ct_subtypes/admci/ct_sc11_sub_20161013/';

net = [1 2 3 6];

for nn = 1:4
    ss = net(nn)
    files_in = strcat(path_data, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_data, 'net', num2str(ss), '/figures');
    psom_mkdir(opt.folder_out)
    opt.nb_subtype = 4;
    
    adsf_brick_visu_ct_sub(files_in,files_out,opt);
    clear files_in
end

%% weight extraction

clear all
path_stack = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/basc_sc4_stacks/regress_agesexmeanct/';
path_sub = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/admci_ct/ct_sc4_sub_20161012/';

net = [1 2 3 6];

for nn = 1:4
    ss = net(nn)
    files_in.data.net = strcat(path_stack, 'ct_network_', num2str(ss), '_stack.mat');
    files_in.subtype.net = strcat(path_sub, 'net', num2str(ss), '/subtype.mat');
    files_out = struct;
    opt.folder_out = strcat(path_sub, 'net', num2str(ss));
    
    adsf_brick_subtype_weight(files_in,files_out,opt);
    clear files_in
end