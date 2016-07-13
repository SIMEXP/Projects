%%%%%%%%% generate labels for clusters


%% extract each network in scale 12

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/template_mcinet_basc_sym_clusters_nii/';
path_out = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/scale_12_networks_sym/';
scale12 = [path_data 'brain_parcellation_mcinet_basc_sym_12clusters.nii.gz'];
[hdr,mask] = niak_read_vol(scale12);
networks = [1 2 3 4 5 6 7 8 9 10 11 12];

for nn = 1:length(networks)
    net = networks(nn);
    submask = zeros(size(mask));
    submask(mask==net) = 1;
    hdr.file_name = strcat(path_out, 'network_', num2str(net), '.nii.gz');
    niak_write_vol(hdr,submask);
end

%% sort the clusters to a reference

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/';
path_clus = [path_data 'template_mcinet_basc_sym_clusters_nii/'];
path_out = [path_clus 'labels_sc12/'];

network = {'attention_post','basalganglia_thalamus','cerebellum','dmn_ant','dmn_post','insula','limbic_ant','sensorymotor','network_3','network_4','network_5','visual'}; % names of networks in scale 6
%nb_clus = [17 30 51 77 137 199 322]; % rois
nb_clus = [12 22 33 65 111 208]; % scales

for cc = 1:length(network)
    files_in.cluster = strcat(path_data, 'scale_12_networks_sym/', network{cc}, '_res12.nii.gz');
    for nn = 1:length(nb_clus)
        files_in.subcluster = [path_clus 'brain_parcellation_mcinet_basc_sym_' num2str(nb_clus(nn)) 'clusters.nii.gz'];
        files_out = struct;
        files_out.subcluster = {strcat(path_out, network{cc}, '_res', num2str(nb_clus(nn)), '.nii.gz')};
        files_out.matching = strcat(path_out, network{cc}, '_res', num2str(nb_clus(nn)), '.mat');
        opt.perc_overlap = 0.5;
        niak_brick_subclusters(files_in,files_out,opt);
    end
end

%% make the labels

% need to load "matching" .mat file from niak_brick_subclusters

% create the cell array
labels = cell(length(matching{1})+1,2);

% make the headers
labels{1,1} = 'Label';
labels{1,2} = 'Seed number';

% cell contents
for nn = 1:length(matching{1})
    labels{nn+1,1} = strcat('dmn_ant_',num2str(nn)); % generate the label
    labels{nn+1,2} = matching{1}(nn); % extract the seed number
end

% write the csv
fid = fopen('labels_dmn_ant_sc208.csv','w'); % 
fprintf(fid, '%s, %s\n', labels{1,:});
for cc = 1:length(matching{1})
    fprintf(fid, '%s, %d\n', labels{cc+1,:});
end
fclose(fid)









