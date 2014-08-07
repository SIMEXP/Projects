%% Build a mask from all the partitions
temp_path = '/data1/abide/Mask/basc_group_masks/stability_group/';
file_temp = 'part_sc%d_resampled.nii.gz';
out_path = '/data1/abide/Mask/basc_group_masks/stability_group/part_res.mat';
mask_path = '/data1/abide/Mask/basc_group_masks/stability_group/mask_resample.nii.gz';
out_mask = '/data1/abide/Mask/basc_group_masks/stability_group/mask_data_specific.nii.gz';

scales = [10 50 100 200 500];

part = struct;
part.scale = scales;
count = 1;

[mhdr, mvol] = niak_read_vol(mask_path);
mask = logical(mvol);

for scale = scales
    file_name = [temp_path sprintf(file_temp, scale)];
    if exist(file_name, 'file')
        fprintf('Getting %s now\n', file_name);
        [phdr, pvol] = niak_read_vol(file_name);
        part_mask = logical(pvol);
        conj_mask = mask & part_mask;
        tmp_part = pvol(conj_mask);
        fprintf('    The partition has a size of %d\n', size(tmp_part, 1));
        part.part(:, count) = tmp_part;
        count = count + 1;
    else
       warning([file_name ' does not exist\n']);
       continue
    end
end

mhdr.file_name = out_mask;
niak_write_vol(mhdr, conj_mask);
save(out_path, '-struct', 'part');
