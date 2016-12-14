
%http://niak.simexp-lab.org/niak_tutorial_rmap_connectome.html
%http://niak.simexp-lab.org/pipe_connectome.html

clear

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-v0.17.0/'))
path_data = '/gs/project/gsf-624-aa/simons_vip/';
%files_in.fmri = niak_grab_fmri_preprocess('/gs/project/gsf-624-aa/simons_vip/svip_prep_test_rest1_2_10_27/').fmri;

opt_g.exclude_subject = {'s14725xx46xFCAP1','s14725xx51xFCAP1', 's14784xx15xFCAP1', 's14785xx5xFCAP1', 's14871xx1xFCAP1', 's14927xx1xFCAP1', 's14928xx1xFCAP1', 's14952xx5xFCAP1', 's14983xx1xFCAP1'};
opt_g.min_nb_vol = 50; % the demo dataset is very short, so we have to lower considerably the minimum acceptable number of volumes per run
opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline
files_in = niak_grab_fmri_preprocess('/gs/project/gsf-624-aa/simons_vip/svip_prep_test_rest1_2_10_27',opt_g);



%[status,msg,data_template] = niak_wget('cambridge_template_mnc1');
%files_in.network = [data_template.path filesep 'template_cambridge_basc_multiscale_sym_scale007.mnc.gz'];
files_in.network = '/gs/project/gsf-624-aa/simons_vip/template/template_cambridge_basc_multiscale_asym_scale012.nii.gz' ;

files_in.seeds = [path_data 'list_seeds.csv'];
opt_csv.labels_x = { 'Basal_Ganglia' , 'Auditory', 'Limbic', 'Lateral_DMN' , 'Visual', 'Post_medial_DMN', 'Somatomotor', 'Ant_DMN', 'Upstream_visual', 'Fronto_parietal', 'Ventral_att', 'Cerebellum' }; % The labels for the network
opt_csv.labels_y = { 'index' };
tab = [1 ; 2 ; 3; 4; 5; 6; 7 ; 8 ; 9; 10 ; 11; 12];
niak_write_csv(files_in.seeds,tab,opt_csv);

opt.folder_out = [path_data 'connectome'];

opt.flag_p2p = false; % No parcel-to-parcel correlation values
opt.flag_global_prop = false; % No global graph properties
opt.flag_local_prop  = false; % No local graph properties
opt.flag_rmap = true; % Generate correlation maps

opt.flag_test = false; 
[pipeline,opt] = niak_pipeline_connectome(files_in,opt); 


%%%%%%%%%%%%% to modify
file_Basal_Ganglia   = [opt.folder_out filesep 'rmap_seeds' filesep 'rmap_subject1_DMN.nii.gz'];
file_motor = [opt.folder_out filesep 'rmap_seeds' filesep 'rmap_subject1_MOTOR.nii.gz'];
[hdr,rmap_dmn]   = niak_read_vol(file_dmn);
[hdr,rmap_motor] = niak_read_vol(file_motor);
size(rmap_dmn)
size(rmap_motor)

% The default-mode network
coord = linspace(-20,40,10)';
coord = repmat(coord,[1 3]);
opt_v = struct;
opt_v.type_view = 'axial';
img_dmn = niak_vol2img(hdr,rmap_dmn,coord,opt_v);
imshow(img_dmn,[0,1])

% The sensorimotor network
img_motor = niak_vol2img(hdr,rmap_motor,coord,opt_v);
imshow(img_motor,[0,1])

file_mask_dmn   = [opt.folder_out filesep 'rmap_seeds' filesep 'mask_DMN.nii.gz'];
[hdr,mask_dmn]   = niak_read_vol(file_mask_dmn);
img_mask_dmn = niak_vol2img(hdr,mask_dmn,coord,opt_v);
imshow(img_mask_dmn,[0,1])
