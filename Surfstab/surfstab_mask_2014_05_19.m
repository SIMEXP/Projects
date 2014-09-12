%% Build a mask from all the partitions
temp_path = '/home/surchs/Projects/stability_abstract/';
file_temp = 'brain_partition_consensus_group_sci%d_scg%d_scf%d.mnc.gz';
out_path = '/home/surchs/Projects/stability_abstract/part.mat';
mask_path = '/home/surchs/Projects/stability_abstract/mask.mnc.gz';


scales = [10 50 100 200 500];

part = struct;
part.scale = scales;
count = 1;

for scale = scales
    file_name = [temp_path sprintf(file_temp, scale, scale, scale)];
    if exist(file_name, 'file')
        fprintf('Getting %s now\n', file_name);
        [phdr, pvol] = niak_read_vol(file_name);
        mask = logical(pvol);
        tmp_part = pvol(mask);
        fprintf('    The partition has a size of %d\n', size(tmp_part, 1));
        part.part(:, count) = tmp_part;
        count = count + 1;
    else
       warning([file_name ' does not exist\n']);
       continue
    end
end

mhdr = phdr;
mhdr.file_name = mask_path;
niak_write_vol(mhdr, mask);
save(out_path, '-struct', 'part');
