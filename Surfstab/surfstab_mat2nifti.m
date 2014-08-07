function [out, vol] = surfstab_mat2nifti(mat, mask, out)
% Function that maps a matlab vector to a nfiti file. The mask that has to
% be supplied with the vector will be used as a binary mask to map the
% vector into volume
fprintf('Going to dump into\n    %s\naccording to\n    %s\n', out, mask);
[hdr, mvol] = niak_read_vol(mask);
mask_vol = round(mvol);
mask = logical(mask_vol);
vol = niak_part2vol(mat, mask);
out_hdr = hdr;
out_hdr.file_name = out;
niak_write_vol(out_hdr, vol);
fprintf('\n\nDone, wrote at %s\n', out);
