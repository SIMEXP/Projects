%% script to combine civet vertex based measures of the adnet sample together

clear all

data = '/gs/project/gsf-624-aa/database2/adnet/civet_20160913/thickness_files_vertex/';

model = '/home/atam/scratch/ct_subtypes/admci/model/admci_model_20160401_civet.csv'; 

hemi = {'left','right'};


[tab,list_subject,ly] = niak_read_csv(model);


% filter out the failed QC civet subjects
mask = find(tab(:,13) == 0);
list_subject = 

for ss = 1:length(list_subject)
    name = list_subject(ss);
    
    for hh = 1:2
        side = hemi(hh);
        exp_tmp = '_native_rms_rsl_tlink_30mm_';
        file = strcat('adnet_', name, exp_tmp, side, '.txt');
        file1=file{1};
        
        if hh == 1
            import_left = importdata([data file1]);  % import left .txt file for a subject
            left = import_left';  % rearrange data horizontally
        else
            import_right = importdata([data file1]);  % import right .txt file for a subject
            right = import_right';
        end
        
    end
    whole = [left right];
    ct(ss,:) = whole; 
end


file_write = [data 'admci_civet_vertex_20160916.mat'];
save(file_write,'ct','list_subject');