clear all

path_data = '/home/pbellec/database/local_fdr/';
path_res = [path_data 'res_2015_10_07' filesep];
path_glm = [path_data 'pce_glm_connectome' filesep];

list_contrast = {'motor','blind','schizo'};
list_sc = { '35' , '308' ; '40' , '313' ; '55' , '328'};
list_max = [0.2 0.05 0.4];
for cc = 1:length(list_contrast)
    for ss = 1:size(list_sc,2)
        opt_v.vol_limits = [0 list_max(cc)];
        opt_v.flag_colorbar = true;
        file_test = [path_res list_contrast{cc} '_sc' list_sc{cc,ss} '.txt_OUTPUT.txt'];
        file_net = [path_glm list_contrast{cc} '_sc' list_sc{cc,ss} '.nii.gz'];
        file_pce = [path_glm list_contrast{cc} '_sc' list_sc{cc,ss} '.txt'];
        
        [hdr,vol] = niak_read_vol(file_net);
        test = load(file_test);
        test = niak_lvec2mat(test);
        pce = load(file_pce);
        [fdr_bh,test_bh] = niak_fdr(pce(:),'BH',0.05);
        disc = niak_part2vol(mean(test,1),vol);
        hdr.file_name =  [path_res list_contrast{cc} '_sc' list_sc{cc,ss} '_disc.nii.gz'];
        niak_montage(disc);
        print([path_res list_contrast{cc} '_sc' list_sc{cc,ss} '_disc.png'],'-dpng');
        disc_bh = niak_part2vol(mean(niak_lvec2mat(test_bh),1),vol);
        hdr.file_name =  [path_res list_contrast{cc} '_sc' list_sc{cc,ss} '_disc_bh.nii.gz'];
        niak_write_vol(hdr,disc_bh);
        niak_montage(disc_bh);
        print([path_res list_contrast{cc} '_sc' list_sc{cc,ss} '_disc_bh.png'],'-dpng');
    end
end

% mricron /home/pbellec/database/template.nii.gz -c -0 -o motor_sc308_disc.nii.gz -c 5redyell -l 0.01 -h 0.2 
% mricron /home/pbellec/database/template.nii.gz -c -0 -o motor_sc308_disc_bh.nii.gz -c 5redyell -l 0.01 -h 0.2 
% mricron /home/pbellec/database/template.nii.gz -c -0 -o blind_sc313_disc_bh.nii.gz -c 5redyell -l 0.01 -h 0.05 
% mricron /home/pbellec/database/template.nii.gz -c -0 -o blind_sc313_disc.nii.gz -c 5redyell -l 0.01 -h 0.05 
% mricron /home/pbellec/database/template.nii.gz -c -0 -o schizo_sc328_disc.nii.gz -c 5redyell -l 0.01 -h 0.4
% mricron /home/pbellec/database/template.nii.gz -c -0 -o schizo_sc328_disc_bh.nii.gz -c 5redyell -l 0.01 -h 0.4
