% script to calculate mean GM density in the whole brain for adni dartel

clear all

% set the inputs
path_stack = '/home/angela/Desktop/adsf/adni_dartel/stack_mnc/stack_4d.mnc.gz';
path_mask = '/home/angela/Desktop/adsf/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';
path_model = '/home/angela/Desktop/adsf/adni_dartel/model/adni_dartel_model_20160913.csv';

% read the volumes
[hdr_vol,vol] = niak_read_vol(path_stack);
[hdr_mask,mask] = niak_read_vol(path_mask);

% read the model
[tab,list_id,ly] = niak_read_csv(path_model);

% make mask logical
mask = mask > 0; 

% prep the csv

labels = cell(size(vol,4),2);
labels{1,1} = 'subject';
labels{1,2} = 'mean_gm';

csvname = 'adni_dartel_mean_gm_wholebrain.csv';
fid = fopen(csvname,'w');
fprintf(fid, '%s, %s\n', labels{1,:});

% calculate the gm average

for ss = 1:size(vol,4) % for every subject in the stack
    labels{ss+1,1} = list_id{ss};
    tmp_vol = vol(:,:,:,ss);
    labels{ss+1,2} = mean(tmp_vol(mask));
    fprintf(fid, '%s, %f\n', labels{ss+1,1}, labels{ss+1,2});
end

fclose(fid)