%%
% Test of the brick
in.anat = 'anat_s0146865_nuc_stereolin.mnc.gz';
in.mask_anat = 'mask_anat2func.mnc.gz';
in.func = 'motion_target_s0146865_sess1_breathHold1400.mnc.gz';
in.transformation_init = 'transf_s0146865_nativet1_to_stereolin.xfm';
opt.flag_invert_transf_init   = true;
out = struct();
out.anat_hires = 'anat_hires.mnc.gz';
niak_brick_anat2func (in,out,opt);

clear
[hdr,volt1] = niak_read_vol('anat_s0146865_nuc_stereolin.mnc.gz');

%% Resample the bold mask in stereolin space
in.source = 'mni_icbm152_t1_tal_nlin_sym_09a_mask_register_bold.mnc.gz';
in.target = 'mni_icbm152_t1_tal_nlin_sym_09a_mask_register_bold.mnc.gz';
in.transformation = 'transf_s0146865_stereolin_to_stereonl.xfm';
out = 'tmp.mnc.gz';
opt.flag_invert_transf = true;
opt.interpolation = 'nearest_neighbour';
niak_brick_resample_vol(in,out,opt);

[hdr,mask_bold] = niak_read_vol('tmp.mnc.gz');
[hdr,mask_brain] = niak_read_vol('anat_s0146865_mask_stereolin.mnc.gz');
[hdr2,mask_ventral] = niak_read_vol('ventral.nii');

%% Extract a csf mask
mask_tissue = niak_kmeans_clustering(volt1(:)',struct('nb_classes',3,'flag_verbose',true));
mask_tissue = reshape(mask_tissue,size(volt1));
valm = zeros(1,3);
for cc = 1:3
    valm(cc) = mean(volt1(mask_tissue==cc));
end
[val,ind] = min(valm);
mask_csf = mask_tissue == ind;

%% Extract a group mask of functional data 
in.source = 'func_mask_average_stereonl.mnc.gz';
in.target = 'mni_icbm152_t1_tal_nlin_sym_09a_mask_register_bold.mnc.gz';
in.transformation = 'transf_s0146865_stereolin_to_stereonl.xfm';
out = 'tmp2.mnc.gz';
opt.flag_invert_transf = true;
opt.interpolation = 'tricubic';
niak_brick_resample_vol(in,out,opt);
[hdr,avg_func] = niak_read_vol('tmp2.mnc.gz');
coord_v = niak_coord_world2vox([0 0 15],hdr.info.mat);
mask_func = avg_func>0.8;

%% Combine the bold, csf and brain masks
mask_brain2 = (mask_brain | (mask_csf & mask_bold))&~mask_ventral;
mask_brain2(:,:,1:ceil(coord_v(3))) = mask_brain2(:,:,1:ceil(coord_v(3)))&mask_func(:,:,1:ceil(coord_v(3)));
hdr.file_name = 'anat_s0146865_mask_bold.mnc.gz';
niak_write_vol(hdr,mask_brain2);

%% now try to register the t1 and bold volumes
load job
job.files_in.func = 'motion_target_s0146865_sess1_breathHold1400.mnc.gz';
job.files_in.anat = 'anat_s0146865_nuc_stereolin.mnc.gz';
job.files_in.transformation_init = 'transf_s0146865_nativet1_to_stereolin.xfm';
job.files_in.mask_anat = 'anat_s0146865_mask_bold.mnc.gz';
job.files_out.transformation = 'transf_s0146865_nativefunc_to_stereolin_bis.xfm';
job.files_out.anat_hires = 'anat_s0146865_nativefunc_hires_bis.mnc.gz';
job.files_out.anat_lowres = 'anat_s0146865_nativefunc_lowres.mnc.gz';
%job.opt.flag_nu_correct = true;
%job.opt.list_fwhm = [8,5,8,4,3];
psom_run_job(job);