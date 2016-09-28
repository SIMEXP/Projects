clear 
%% Create a mask of the brain, expanded to include the surrounding CSF and meninges, up to the bone
%% In the MNI152 stereotaxic template
cd /home/pbellec/git/niak_issue100/template/mni-models_icbm152-nl-2009-1.0
[hdr,vol] = niak_read_vol('mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz');
[hdr,mask_head] = niak_read_vol('mni_icbm152_t1_tal_nlin_sym_09a_headmask.mnc.gz');

%% Segment CSF
tic, seg = niak_kmeans_clustering (vol(:)',struct('nb_classes',3)); toc
seg = reshape(seg,size(vol));

%% Get mean values per class
mval = zeros(3,1);
for cc = 1:3
    mval(cc) = mean(vol(seg==cc));
end
[val,order] = sort(mval);
ind_csf = order(1);
ind_csf2 = order(2);

%% Extract csf
csf = seg==ind_csf;
mask_roi = niak_find_connex_roi(csf&mask_head);
sroi = niak_build_size_roi(mask_roi);
[val,indr] = max(sroi);
extra = mask_roi==indr;
csf2 = extra | seg==ind_csf2;

%% Dilate the brain mask
system('mincmorph -successive DDDDDDDDDD mni_icbm152_t1_tal_nlin_sym_09a_mask.mnc.gz mask_dilated_1cm.mnc -clobber')
[hdr,mask_brain] = niak_read_vol('mni_icbm152_t1_tal_nlin_sym_09a_mask.mnc.gz');
[hdr,mask_brain_dilated1] = niak_read_vol('mask_dilated_1cm.mnc');
[hdr,mask_brain_dilated5] = niak_read_vol('mni_icbm152_t1_tal_nlin_sym_09a_mask_dilated5mm.mnc.gz');
csf2(~mask_brain_dilated1) = false;
csf2(mask_brain_dilated5>0) = true;

%% Finally run a closure and a slight dilation
hdr.file_name = 'tmp.mnc';
niak_write_vol(hdr,csf2);
system('mincmorph -clobber -successive DDDDDEEEE tmp.mnc mni_icbm152_t1_tal_nlin_sym_09a_mask_register_bold.mnc.gz');
