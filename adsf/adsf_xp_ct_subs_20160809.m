clear all

%% generate ct subtypes
files_in.data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/ct_net9_sc9_regress.mat';
files_in.mask = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/mask_net9_sc9.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/net9_5sub/';
opt.nb_subtype = 5;

adsf_brick_subtyping(files_in,files_out,opt);

%% generate figures

in_visu = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/net9_5sub/subtype.mat';
out_visu = struct;
opt_v.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/net9_5sub/figures';
opt_v.nb_subtype = 5;

adsf_visu_ct_subtype(in_visu,out_visu,opt_v);

%% weight extraction

in_w.data.net9 = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/ct_net9_sc9_regress.mat';
in_w.subtype.net9 = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/net9_5sub/subtype.mat';
out_w = struct;
opt_w.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes_20160808/net9_5sub/';

niak_brick_subtype_weight(in_w,out_w,opt_w);
