% script to extract raw cortical thickness values from CIVET outputs in
% ADNI2

clear all

data = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2_civet_data/thickness_vertices/';

model = '/Users/AngelaTam/Desktop/adsf/adni2_weights_vbm_rs_ct_model.csv';

hemi = {'left','right'};

[tab,list_subject,ly] = niak_read_csv(model);

for ss = 1:length(list_subject)
    name = list_subject(ss);
    
    for hh = 1:2
        side = hemi(hh);
        exp_tmp = 'native_rms_rsl_tlink_30mm_';
        file = strcat('adni2_', name,'_',exp_tmp, side, '.txt');
        file1=file{1};
        
        if ~exist(file1)
            left = NaN(1,40962);
            right = NaN(1,40962);
        else
            if hh == 1
                import_left = importdata([data file1]);  % import left .txt file for a subject
                left = import_left';  % rearrange data horizontally
            else
                import_right = importdata([data file1]);  % import right .txt file for a subject
                right = import_right';
            end
        end
        
    end
    whole = [left right];
    ct(ss,:) = whole; 
end

file_write = [data 'adni2_raw_ct_vertex_20170122.mat'];
save(file_write,'ct','list_subject');