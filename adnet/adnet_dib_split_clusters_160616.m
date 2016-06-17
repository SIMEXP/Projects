%% script to split clusters for mcinet basc parcellations

clear all

path_data = '/home/atam/scratch/data_in_brief/template_mcinet_basc_sym_mnc/';

n_clus = [4 6 12 22 33 65 111 208];

for nn = 1:length(n_clus)
    file_name = strcat(path_data, 'brain_parcellation_mcinet_basc_sym_', num2str(n_clus(nn)), 'clusters.mnc.gz');
    out_name = strcat(path_data, 'brain_parcellation_mcinet_basc_sym_', num2str(n_clus(nn)), 'clusters_split.mnc.gz');
    files_in = file_name;
    files_out = out_name;
    niak_brick_split_clusters(files_in,files_out);
end

%% script to make asymmetric versions of ROIs

clear all

files_in.transformation = '/home/atam/git/niak/template/mni-models_icbm152-nl-2009-1.0/sym2asym.xfm';
opt.folder_out = '/home/atam/scratch/data_in_brief/template_mcinet_basc_asym_rois_mnc/';

path_data = '/home/atam/scratch/data_in_brief/template_mcinet_basc_sym_rois_mnc/';

n_rois = [10 17 30 51 77 137 199 322];

for nn = 1:length(n_rois)
    file_name = strcat(path_data, 'brain_parcellation_mcinet_basc_sym_', num2str(n_rois(nn)), 'rois.mnc.gz');
    out_name = strcat('brain_parcellation_mcinet_basc_asym_', num2str(n_rois(nn)), 'rois.mnc.gz');
    files_in.source = file_name;
    files_out = out_name;
    niak_brick_resample_vol(files_in,files_out,opt);
end