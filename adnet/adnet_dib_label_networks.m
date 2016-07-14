%%%%%%%%% generate labels for clusters

%% sort the clusters to a reference (scale 12)

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/';
path_clus = [path_data 'template_mcinet_basc_sym_clusters_nii/'];
files_in.cluster = strcat(path_clus, 'brain_parcellation_mcinet_basc_sym_12clusters.nii.gz');

%nb_clus = [17 30 51 77 137 199 322]; % rois
scale = [22 33 65 111 208]; % scales

for cc = 1:length(scale)
        files_in.subcluster = [path_clus 'brain_parcellation_mcinet_basc_sym_' num2str(scale(cc)) 'clusters.nii.gz'];
        files_out = struct;
        opt.folder_out = strcat(path_clus, 'sc12_to_sc', num2str(scale(cc)));
        files_out.subcluster = '';
        files_out.matching = strcat(opt.folder_out, filesep, 'labels_sc12_to_sc', num2str(scale(cc)), '.mat');
        niak_brick_subclusters(files_in,files_out,opt);
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









