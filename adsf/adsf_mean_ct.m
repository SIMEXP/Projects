%% calculate mean cortical thickness across the brain for every subject

clear all

load preventad_civet_vertex_bl_20160216

labels = cell(223,2);
labels{1,1} = 'subject';
labels{1,2} = 'mean_ct';

csvname = 'raw_whole_brain_mean_ct.csv';
fid = fopen(csvname,'w');
fprintf(fid, '%s, %s\n', labels{1,:});

for ss = 1:222
    labels{ss+1,1} = subjects{ss};
    labels{ss+1,2} = mean(ct(ss,:));
    fprintf(fid, '%s, %d\n', labels{ss+1,:});
end

%% calculate mean thickness for one network per subject

clear all

for net = 1:9  % for all 9 networks
    % load the files
    ct_file = strcat('ct_network_', num2str(net), '_stack.mat');
    mask_file = strcat('mask_network', num2str(net), '.mat');
    load(mask_file); % loading mask for network
    n_vox = sum(mask); % number of vertices within network mask
    load(ct_file); % loading raw stack file
    
    % set up the csv
    labels = cell(223,2);
    labels{1,1} = 'subject';
    labels{1,2} = strcat('mean_ct_net',num2str(net));
    csvname = strcat('raw_whole_brain_mean_ct_net', num2str(net), '.csv');
    fid = fopen(csvname,'w');
    fprintf(fid, '%s, %s\n', labels{1,:});
    
    % fill in the cells
    for ss = 1:222 % for all 222 subjects
        labels{ss+1,1} = provenance.subjects{ss};
        labels{ss+1,2} = sum(stack(ss,:))/n_vox;
        fprintf(fid, '%s, %d\n', labels{ss+1,:});
    end
    fclose(fid)
end
    
    
    