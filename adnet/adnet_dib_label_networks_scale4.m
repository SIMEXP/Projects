%%%%%%%%% generate labels for ROIs at scale 4


%% extract each network in scale 4

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/parcellations/template_mcinet_basc_sym_clusters_nii/';
path_out = '/Users/AngelaTam/Desktop/data_in_brief/parcellations/scale_4_networks_sym/';
scale4 = [path_data 'brain_parcellation_mcinet_basc_sym_4clusters.nii.gz'];
[hdr,mask] = niak_read_vol(scale4);
networks = [1 2 3 4];

for nn = 1:length(networks)
    net = networks(nn);
    submask = zeros(size(mask));
    submask(mask==net) = 1;
    hdr.file_name = strcat(path_out, 'network_', num2str(net), '.nii.gz');
    niak_write_vol(hdr,submask);
end

%% make the labels

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/parcellations/';
path_clus = [path_data 'template_mcinet_basc_sym_rois_nii/'];
path_out = [path_clus 'labels/'];

network = {'cerebellum_limbic','dmn_salience','motor','visual'}; % names of networks in scale 6
nb_clus = 10; % rois

for cc = 1:length(network)
    files_in.cluster = strcat(path_data, 'scale_4_networks_sym/', network{cc}, '_res4.nii.gz');
    for nn = 1:length(nb_clus)
        files_in.subcluster = [path_clus 'brain_parcellation_mcinet_basc_sym_' num2str(nb_clus(nn)) 'rois.nii.gz'];
        files_out = struct;
        files_out.subcluster = {strcat(path_out, network{cc}, '_res', num2str(nb_clus(nn)), '.nii.gz')};
        opt.perc_overlap = 0.5;
        niak_brick_subclusters(files_in,files_out,opt);
    end
end




