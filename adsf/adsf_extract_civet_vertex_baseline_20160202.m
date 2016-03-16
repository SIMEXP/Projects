clear all

data = '/Users/AngelaTam/Desktop/adsf/structure_data/cortical_thickness/thickness_files_bl_vertex_20150831/';

model = '/Users/AngelaTam/Desktop/adsf/model/preventad_model_vol_bl_dr2_20160316_qc.csv'; % csv with failed QCs removed

hemi = {'left','right'};


[tab,list_subject,ly] = niak_read_csv(model);

for ss = 1:length(list_subject)
    name = list_subject(ss);
    name1 = name{1};
    name2 = name1(2:7);
    type = name1(8:10);
    
    for hh = 1:2
        side = hemi(hh);
        exp_tmp = 'BL00_adniT1_001_native_rms_rsl_tlink_30mm_';
        file = strcat('PreventAD_', name2,'_',type ,exp_tmp, side, '.txt');
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


file_write = [data 'preventad_civet_vertex_bl_20160316.mat'];
save(file_write,'ct','list_subject');
    


    
    
    





