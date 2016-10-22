%% script to combine civet vertex based measures of the cambridge sample together

clear all

data = '/home/atam/scratch/ct_subtypes/cambridge/cambridge_civet/thickness_vertex/';

model = '/home/atam/scratch/ct_subtypes/cambridge/model_cambridge.csv'; 

hemi = {'left','right'};


[tab,subjects,ly] = niak_read_csv(model);

for ss = 1:length(subjects)
    name = subjects(ss);
    
    for hh = 1:2
        side = hemi(hh);
        exp_tmp = '_native_rms_rsl_tlink_30mm_';
        file = strcat('cambridge_', name, exp_tmp, side, '.txt');
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


file_write = [data 'cambridge_civet_vertex_20160929.mat'];
save(file_write,'ct','subjects');