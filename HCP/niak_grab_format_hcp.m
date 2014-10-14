



list_subject = {'s1','s2',...};

for ss = 1:length(list_subject)
    subject = list_subject{ss};
    file_name = [path_data 'mask_' subject '.nii.gz'];
    [hdr,mask] = niak_read_vol(file_name);
    if ss = 1
        mask_avg = mask;
    else
        mask_avg = mask+mask_avg;
    end
end
mask_avg = mask_avg/length(list_subject);

mask_group = mask_avg > 0.5;

niak_montage(mask_avg);
niak_montrage(mask_group);