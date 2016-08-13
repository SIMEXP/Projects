%% calculate mean cortical thickness across the brain for every subject

clear all

load preventad_civet_vertex_bl_20160216

labels = cell(223,2);
labels{1,1} = 'subject';
labels{1,2} = 'mean_ct';

csvname = 'raw_whole_brain_mean_ct.csv';
fid = fopen(csvname,'w');
fprintf(fid, '%s, %s\n', labels{1,:});

for ss = 1:222
    labels{ss+1,1} = subjects{ss};
    labels{ss+1,2} = mean(ct(ss,:));
    fprintf(fid, '%s, %d\n', labels{ss+1,:});
end
