% Now with the bootstrap
clear
path_data = '/home/pbellec/database/stability_surf/';


%in.part = [path_data 'basc_cambridge_sc10.nii.gz'];
in.part = [path_data 'preproc' filesep 'trt' filesep 'part_sc10_resampled.nii.gz'];
opt.sampling.type = 'CBB';

% Scale 10
list_subject = {'sub90179','sub94293'};
pipe = struct();
for ss = 1:length(list_subject)
    subject = list_subject{ss};
    for rr = 1:3
        in.fmri = [path_data 'preproc' filesep 'trt' filesep 'fmri_' subject '_session' num2str(rr) '_rest.mnc.gz'];
        opt.folder_out = [path_data 'xp_pb_trt_2014_06_08d' filesep subject '_sess' num2str(rr) filesep];
        pipe = psom_add_job(pipe,[subject '_sess' num2str(rr)],'niak_brick_scores_fmri_v2',in,struct(),opt);
    end
end

opt_p.path_logs = [path_data 'xp_pb_trt_2014_06_08d' filesep 'logs'];
% mricron /home/pbellec/database/template.nii.gz -c -0 -o stability_maps.nii.gz -c 5redyell -l 0.05 -h 1&
% niak_brick_mnc2nii('/home/pbellec/database/stability_surf/xp_pb_trt_2014_06_08d')

clear
list_subject = {'sub90179','sub94293'};
[hdr,mask] = niak_read_vol(['/home/pbellec/database/stability_surf/preproc' filesep 'trt' filesep 'part_sc10_resampled.nii.gz']);
mask = mask>0;
for ss = 1:length(list_subject)
    subject = list_subject{ss};
    for rr = 1:3
        cd(['/home/pbellec/database/stability_surf/xp_pb_trt_2014_06_08d/' subject '_sess' num2str(rr)])
        [hdr,vol] = niak_read_vol ('stability_maps.mnc.gz'); 
        vol = vol(:,:,:,7);        
        if (ss==1)&&(rr==1)
            y = zeros(sum(mask(:)),length(list_subject));
        end
        y(:,rr+((ss-1)*3)) = vol(mask);       
    end
end
