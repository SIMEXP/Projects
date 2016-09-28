% script to calculate mean GM density in the basc gm networks for adni dartel

clear all

% set the inputs
path_stack = '/home/atam/scratch/adni_dartel/stack_mnc_20160912/stack_4d.mnc.gz';
path_mask = '/home/atam/scratch/adni_dartel/basc_msteps_20160912_1/stability_ind/adni/sci5_scf4/brain_partition_consensus_ind_adni_sci5_scf4.mnc.gz';
path_model = '/home/atam/scratch/adni_dartel/model/adni_dartel_model_20160913.csv';

% read the volumes
[hdr_vol,vol] = niak_read_vol(path_stack);
[hdr_mask,mask] = niak_read_vol(path_mask);

% read the model
[tab,list_id,ly] = niak_read_csv(path_model);

for nn = 1:max(mask(:))
    % define mask
    n_mask = mask == nn; 

    % prep the csv

    labels = cell(size(vol,4),2);
    labels{1,1} = 'subject';
    labels{1,2} = 'mean_gm';

    csvname = strcat('adni_dartel_mean_gm_net', num2str(nn), '.csv');
    fid = fopen(csvname,'w');
    fprintf(fid, '%s, %s\n', labels{1,:});

    % calculate the gm average

    for ss = 1:size(vol,4) % for every subject in the stack
        labels{ss+1,1} = list_id{ss};
        tmp_vol = vol(:,:,:,ss);
        labels{ss+1,2} = mean(tmp_vol(n_mask));
        fprintf(fid, '%s, %f\n', labels{ss+1,1}, labels{ss+1,2});
    end

    fclose(fid)
end