%%%%%%%%% generate labels for clusters

%% sort the clusters to a reference (scale 12)

clear all

path_data = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/';
path_clus = [path_data 'template_mcinet_basc_asym_clusters_nii/'];
path_out = [path_data 'template_mcinet_basc_asym_rois_nii/'];
files_in.cluster = strcat(path_clus, 'brain_parcellation_mcinet_basc_asym_12clusters.nii.gz');

scale = [30 51 77 137 199 322]; % rois
% scale = [22 33 65 111 208]; % scales

for cc = 1:length(scale)
        files_in.subcluster = [path_out 'brain_parcellation_mcinet_basc_asym_' num2str(scale(cc)) 'rois.nii.gz'];
        files_out = struct;
        psom_mkdir(strcat(path_out, 'sc12_to_r', num2str(scale(cc))));
        opt.folder_out = strcat(path_out, 'sc12_to_r', num2str(scale(cc)));
        files_out.subcluster = '';
        files_out.matching = strcat(opt.folder_out, filesep, 'labels_sc12_to_r', num2str(scale(cc)), '.mat');
        niak_brick_subclusters(files_in,files_out,opt);
end

%% make the labels

clear all
path_data = '/Users/AngelaTam/Desktop/data_in_brief/label_subclusters/template_mcinet_basc_asym_rois/';
path_out = '/Users/AngelaTam/Desktop/data_in_brief/vol_parcellations/template_mcinet_basc_asym_rois_nii/';
%scale = [22 33 65 111 208]; % scale
scale = [30 51 77 137 199 322]; % rois
cluster = {'DGMN','pDMN',...
    'mTL','vTL','dTL',...
    'aDMN','OFC','pATT',...
    'CER','SM','VIS','FPN'};

for ss = 1:length(scale) % for every scale
    
    % load "matching" .mat file from niak_brick_subclusters
    filename = strcat(path_data, 'sc12_to_r', num2str(scale(ss)), filesep, 'labels_sc12_to_r', num2str(scale(ss)), '.mat');
    load(filename)
    
    % create the cell array2
    labels = cell(scale(ss)+1,2);
    % make the headers
    labels{1,1} = 'Label';
    labels{1,2} = 'Seed number';
    
    % prep the csv
    csvname = strcat(path_out, 'labels_mcinet_asym_', num2str(scale(ss)), 'rois.csv');
    fid = fopen(csvname,'w');
    fprintf(fid, '%s, %s\n', labels{1,:});
    
    for pp = 1:scale(ss) % for every cluster in target scale
        for nn = 1:length(matching) % for each cluster in reference scale 12
            for bb = 1:length(matching{nn}) % for each subcluster in a cluster in scale 12
                % cell contents
                labels{matching{nn}(bb)+1,1} = strcat('R',num2str(scale(ss)),'_',cluster{nn},'_',num2str(bb)); % generate the label
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









