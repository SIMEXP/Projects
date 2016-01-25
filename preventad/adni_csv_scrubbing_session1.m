clear

path = '/Users/pyeror/Work/transfert/PreventAD/group_motion_adni/';

file_template = 'subject[0-9]*_session1_r1d[0-9]*';

[tab,labels_x,labels_y,labels_id] = niak_read_csv([path 'qc_scrubbing_group.csv']);

sub = 0;

for n = 1:length(labels_x)
    
    in_string = labels_x(n);
    
    start = regexp(in_string, file_template);
    session = start{1};
    
    if ~isempty(session)
    
    sub = sub +1;
        expression = 'subject[0-9]*';
        matchStr = regexp(in_string,expression,'match');
        name_new = matchStr{1};
        labels_x_new(sub,1) = name_new;
        labels_x_new2(sub,1) = in_string;
        tab_new(sub,:) = tab(n,:);
    end
    
end


opt.labels_y = labels_y;
opt.precision = 3;

opt.labels_x = labels_x_new;
path_res = [path 'adni_qc_scrubbing_session1.csv'];
niak_write_csv(path_res,tab_new,opt);

opt.labels_x = labels_x_new2;
path_res = [path 'adni_qc_scrubbing_session1_fullname.csv'];
niak_write_csv(path_res,tab_new,opt);
