clear

path = '/Users/pyeror/Work/transfert/PreventAD/';
model_tmp = [path 'models/admci_model_subtype_tmp.csv'];
sample_tag = {'subject','AD0','ad_dat','ad_hc','SB_30','ad_00','ad_10'}; 
% {'adni2','adpd','belleville','belleville','criugm_mci','mni_mci','mni_mci'};

[tab_tmp,id,ly_tmp,~] = niak_read_csv(model_tmp);


tab = tab_tmp;
v = size(tab_tmp,1);
vv = size(tab_tmp,2);
tab(:,vv+1:vv+4) = NaN(v,4);


for ii = 1:length(id)
    
    sub = id{ii}
    
    for tt = 1:length(sample_tag)
        
        tag = sample_tag{tt};
        study = findstr(tag,sub);
        
        if ~isempty(study)
            
            if tt == 1
                qc = [];
                id_qc = [];
                [qc,id_qc,ly_qc,~] = niak_read_csv([path 'data/qc_scrubbing_group_adni2.csv']);
                tag_qc = [sub '_session1'];
                for nn = 1:length(id_qc)
                    sub_qc = id_qc{nn};
                    match = findstr(tag_qc,sub_qc);
                    if ~isempty(match)
                        tab(ii,vv+1:vv+4) = qc(nn,1:4);
                    end
                end
                
            elseif tt == 2
                qc = [];
                id_qc = [];
                [qc,id_qc,~,~] = niak_read_csv([path 'data/qc_scrubbing_group_adpd.csv']);
                tag_qc = [sub '_session1_rest1'];
                for nn = 1:length(id_qc)
                    sub_qc = id_qc{nn};
                    match = findstr(tag_qc,sub_qc);
                    if ~isempty(match)
                        tab(ii,vv+1:vv+4) = qc(nn,1:4);
                    end
                end
                
            elseif tt == 3 | tt == 4
                qc = [];
                id_qc = [];
                [qc,id_qc,~,~] = niak_read_csv([path 'data/qc_scrubbing_group_belleville.csv']);
                tag_qc = [sub '_session1_rest'];
                for nn = 1:length(id_qc)
                    sub_qc = id_qc{nn};
                    match = findstr(tag_qc,sub_qc);
                    if ~isempty(match)
                        tab(ii,vv+1:vv+4) = qc(nn,1:4);
                    end
                end
                
            elseif tt == 5
                qc = [];
                id_qc = [];
                [qc,id_qc,~,~] = niak_read_csv([path 'data/qc_scrubbing_group_criugm_mci.csv']);
                tag_qc = [sub '_session1_rest'];
                for nn = 1:length(id_qc)
                    sub_qc = id_qc{nn};
                    match = findstr(tag_qc,sub_qc);
                    if ~isempty(match)
                        tab(ii,vv+1:vv+4) = qc(nn,1:4);
                    end
                end
                
            elseif tt == 6 | tt == 7
                qc = [];
                id_qc = [];
                [qc,id_qc,~,~] = niak_read_csv([path 'data/qc_scrubbing_group_mni_mci.csv']);
                tag_qc = [sub '_session1_run1'];
                for nn = 1:length(id_qc)
                    sub_qc = id_qc{nn};
                    match = findstr(tag_qc,sub_qc);
                    if ~isempty(match)
                        tab(ii,vv+1:vv+4) = qc(nn,1:4);
                    end
                end
            end        
       end
    end
end

% write csv

ly = ly_tmp;
for n_ly = 1:4
ly{vv+n_ly} = ly_qc{n_ly};
end

opt.labels_x = id;
opt.labels_y = ly;
opt.precision = 3;
file_name = [path 'models/admci_model_subtype_20160219.csv'];
niak_write_csv(file_name,tab,opt)


