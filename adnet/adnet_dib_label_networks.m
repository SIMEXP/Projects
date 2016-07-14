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

clear all
path_data = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/template_mcinet_basc_sym_clusters_nii/';
scale = [22 33 65 111 208];

for ss = 1:length(scale) % for every scale
    
    % load "matching" .mat file from niak_brick_subclusters
    filename = strcat(path_data, 'sc12_to_sc', num2str(scale(ss)), filesep, 'labels_sc12_to_sc', num2str(scale(ss)), '.mat');
    load(filename)
    
    % create the cell array
    labels = cell(scale(ss)+1,2);
    % make the headers
    labels{1,1} = 'Label';
    labels{1,2} = 'Seed number';
    
    % prep the csv
    csvname = strcat(path_data, 'labels_res', num2str(scale(ss)), '.csv');
    fid = fopen(csvname,'w');
    fprintf(fid, '%s, %s\n', labels{1,:});
    
    for pp = 1:scale(ss) % for every cluster in target scale
        for nn = 1:length(matching) % for each cluster in reference scale 12
            for bb = 1:length(matching{nn}) % for each subcluster in a cluster in scale 12
                % cell contents
                labels{matching{nn}(bb)+1,1} = strcat('cluster',num2str(nn),'_',num2str(bb)); % generate the label
                labels{matching{nn}(bb)+1,2} = matching{nn}(bb); % extract the seed number
            end
        end
    end
    
    for pp = 1:scale(ss)
        % write cell contents to csv
        fprintf(fid, '%s, %d\n', labels{pp+1,:});
    end
    fclose(fid)
end









