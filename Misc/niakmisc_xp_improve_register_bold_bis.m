clear
[hdr,volt1] = niak_read_vol('anat_s0146865_nuc_stereolin.mnc.gz');

%% now try to register the t1 and bold volumes
load job
job.files_in.func = 'motion_target_s0146865_sess1_breathHold1400.mnc.gz';
job.files_in.anat = 'anat_s0146865_nuc_stereolin.mnc.gz';
job.files_in.transformation_init = 'transf_s0146865_nativet1_to_stereolin.xfm';
job.files_in.mask_anat = 'anat_s0146865_mask_stereolin.mnc.gz';
job.files_out.transformation = 'transf_s0146865_nativefunc_to_stereolin_bis.xfm';
job.files_out.anat_hires = 'anat_s0146865_nativefunc_hires_bis.mnc.gz';
job.files_out.anat_lowres = 'anat_s0146865_nativefunc_lowres.mnc.gz';
%job.opt.flag_nu_correct = true;
%job.opt.list_fwhm = [8,5,8,4,3];
psom_run_job(job);