%% script to extract fd values from qc_scrubbing_group.csv
clear all

[table,labels_x,labels_y] = niak_read_csv('qc_scrubbing_group.csv');

rest1 = 0;
rest2 = 0;
tag1 = '00_rest1';
tag2 = '00_rest2';
expression = 's[0-9]*[A-Z]*';


for n = 1: length(labels_x)
    
    name = labels_x(n);
    name = name{1};
    t1  = findstr(tag1,name);
    t2  = findstr(tag2,name);
    
    if ~isempty(t1)
        rest1 = rest1+ 1;
        table1(rest1,:) = table(n,:);
        matchStr = regexp(name,expression,'match');
        name_new = matchStr{1};
        labels_x_1{rest1} = name_new;
        labels_check_1{rest1} = name;
    elseif ~isempty(t2)
        rest2 = rest2+1;
        table2(rest2,:) = table(n,:);
        matchStr = regexp(name,expression,'match');
        name_new = matchStr{1};
        labels_x_2{rest2} = name_new;
        labels_check_2{rest2} = name;
    end
end

file_write1 = [pwd filesep 'preventad_fd_rest1.csv'];
opt_1.labels_x = labels_x_1;
opt_1.labels_y = labels_y;
niak_write_csv(file_write1,table1,opt_1)

file_write2 = [pwd filesep 'preventad_fd_rest2.csv'];
opt_2.labels_x = labels_x_2;
opt_2.labels_y = labels_y;
niak_write_csv(file_write2,table2,opt_2)

