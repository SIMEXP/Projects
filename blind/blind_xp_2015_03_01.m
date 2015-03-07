clear all

path_data = '/home/pbellec/database/blindtvr/xp_2015_03/';
% label_contrast = 'rest_CBvsSC';
% label_contrast = 'tvr_CBvsSC';
label_contrast = 'task_CBvsSC';

%% Load partitions
[hdr,sc159] = niak_read_vol([path_data 'networks_sci180_scg162_scf159.nii.gz']);
[hdr,sc8] = niak_read_vol([path_data 'networks_sci11_scg8_scf8.nii.gz']);
mask = sc159>0;
part159 = sc159(mask);
part8 = sc8(mask);
match = niak_match_part(part8,part159);
part8 = match.part2_to_1;
part = zeros(length(unique(part159)),1);
for cc = 1:length(unique(part159))
    part(cc) = unique(part8(part159==cc));
end

%% Load GLM
glm = load([path_data label_contrast '/glm_' label_contrast '_sci180_scg162_scf159.mat']);
model = glm.model_group;
opt_test.q = 0.1;
opt_test.q_omni = 0.05;
opt_test.method = 'TST';
opt_test.nb_samps = 10000;
res = niak_network_fdr(model,part,opt_test);
hdr.file_name = [path_data label_contrast '/perc_disc_network_fdr.nii.gz'];
niak_write_vol(hdr,niak_part2vol(mean(niak_lvec2mat(res.test_fdr{1}),1),sc159));
