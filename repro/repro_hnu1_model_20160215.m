clear

path_pheno = '/Users/pyeror/Work/transfert/repro/models/';
path_motion = '/Users/pyeror/Work/transfert/repro/group_motion/';
model_pheno = 'HNU_1_phenotypic_data_tmp.csv';
model_motion = 'qc_scrubbing_group.csv';

[tab,id,ly,~] = niak_read_csv([path_pheno model_pheno]);
[fd,~,~,~] = niak_read_csv([path_motion model_motion]);

i = 0;
for ii = 1:10:length(id)
    i=i+1;
    new_id{i} = ['s00' id{ii}];
    new_tab(i,1) = tab(ii,2); % age
    new_tab(i,2) = tab(ii,3); % sex
    s = -1;
    for ss = 1:10 % nb sessions
        s=s+1;
        is = ii+s;
        t = 3 +s;
        new_tab(i,t) = tab(is,4); % time-of-day
        tt = 13 + s;
        new_tab(i,tt) = fd(is,3); % fd
        ttt = 23+s;
        new_tab(i,ttt) = fd(is,4); % rfd
    end
end

new_ly{1} = ly{2};
new_ly{2} = ly{3};
for ss = 1:10
    sss = ss+2;
    new_ly{sss} = ['sess_' num2str(ss) '_tod'];
end

for ss = 1:10
    ssss = ss+12;
    new_ly{ssss} = ['sess_' num2str(ss) '_fd'];
end

for ss = 1:10
    sssss = ss+22;
    new_ly{sssss} = ['sess_' num2str(ss) '_rfd'];
end


opt.labels_x = new_id;
opt.labels_y = new_ly;
opt.precision = 3;
file_name = [path_pheno 'hnu1_model_20160215.csv'];

niak_write_csv(file_name,new_tab,opt)
