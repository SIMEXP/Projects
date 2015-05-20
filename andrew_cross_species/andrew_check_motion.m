clear
% Ran the script on the pommier laptop

path_nki = '/home/pbellec/database/nki_enhanced/motion/';
path_preproc = '/home/pbellec/database/nki_enhanced/fmri_preprocess/';
list_seq = {'mx_645','mx_1400','std_2500'};

for num_t = 1:length(list_seq)
    seq = list_seq{num_t};
    file_scrub = [path_preproc '/quality_control/group_motion/qc_scrubbing_group.csv'];
    file_nki = [path_nki 'fd_cpac_' seq '_r1.csv'];

    [tab_scrub,xscrub,yscrub] = niak_read_csv(file_scrub);
    [tab_nki,xnki,ynki] = niak_read_csv(file_nki);
    tab_scrub = tab_scrub(:,3);
    
    nbe = 1;
    for num_e = 1:length(xscrub)
        if any(strfind(xscrub{num_e},strrep(seq,'_','')))
            lx{nbe} = xscrub{num_e}(3:8);
            ind = find(ismember(xnki,lx{nbe}));
            tab(nbe,1) = tab_scrub(num_e);
            tab(nbe,2) = tab_nki(ind);
            nbe = nbe + 1;
        end
    end
    opt.labels_x = lx;
    opt.labels_y = {'fd_mean_niak','fd_mean_cpac'};
    file_write = [path_nki 'motion_niak_vs_cpac_' seq '.csv'];
    niak_write_csv(file_write,tab,opt);
end
            
