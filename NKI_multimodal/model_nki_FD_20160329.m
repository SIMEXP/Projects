%% Model with FD and frameOK values for NKI fifty plus dataset

clear

path = '/Users/pyeror/Work/transfert/NKI/';

runs = {'_sess1_rest645','_sess1_rest1400','_sess1_rest2500'};
opt.labels_y = {'age','sex','hand','release','rFD645','rFD1400','rFD2500','framesOK645','framesOK1400','framesOK2500'};


% Load scrubbing and model files
[tab_1,id_1,~,~] = niak_read_csv([path 'model/nki_model_20160329.csv']);
[tab_2,id_2,~,~] = niak_read_csv([path 'group_motion/qc_scrubbing_group.csv']);


for ii = 1:length(id_1)
    
    tab_out(ii,1:4) = tab_1(ii,1:4);
    opt.labels_x = id_1;
    tag_1 = id_1{ii};
    
    for rr = 1:length(runs)
        
        tag_2 = runs{rr};
        
        for ss = 1:length(id_2)
            name_2 = id_2{ss};
            go_1 = findstr(tag_1,name_2);
            go_2 = findstr(tag_2,name_2);
            
            if ~isempty(go_1)
                if ~isempty(go_2)
                    if rr == 1
                        tab_out(ii,5) = tab_2(ss,4);
                        tab_out(ii,8) = tab_2(ss,2);
                    elseif rr == 2
                        tab_out(ii,6) = tab_2(ss,4);
                        tab_out(ii,9) = tab_2(ss,2);
                    elseif rr == 3
                        tab_out(ii,7) = tab_2(ss,4);
                        tab_out(ii,10) = tab_2(ss,2);
                    end
                    
                end
            end
        end
    end
end

file_name = [path 'model/nki_model_20160329.csv'];
opt.precision = 2;
niak_write_csv(file_name,tab_out,opt)


    
    
    
