clear

data = '/Users/pyeror/Work/transfert/PreventAD/thickness_dat_20150831/';

model = '/Users/pyeror/Work/transfert/PreventAD/models/model_preventad_20160121.csv';

hemi = {'left','right'};


[tab,sid,ly,lx] = niak_read_csv(model);

for s = 1:length(sid)
    name = sid(s);
    name1 = name{1};
    name2 = name1(2:7);
    type = name1(8:10);
    
    for h = 1:2
        side = hemi(h);
        exp_tmp = 'BL00_adniT1_001_lobe_thickness_tlink_30mm_';
        file = strcat('PreventAD_', name2,'_',type ,exp_tmp, side, '.dat');
        file1=file{1};
        
        if h == 1
            import_left = importdata([data file1]);  % import left .dat file for a subject
            left = import_left.data(:,2)';  % rearrange data horizontally
        else
            import_right = importdata([data file1]);  % import left .dat file for a subject
            right = import_right.data(:,2)';
        end
        
    end
    whole = [left right];
    ct(s,:) = whole;
end



file_write = [data 'preventad_civet.csv'];
opt.labels_x = sid;
niak_write_csv(file_write,ct,opt)
    
    
    





