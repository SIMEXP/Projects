clear all

path_data = '/home/pbellec/database/blindtvr/xp_2015_03/';
%label_contrast = 'rest_CBvsSC';
label_contrast = 'tvr_CBvsSC';
%label_contrast = 'task_CBvsSC';

%seeds = [74 75 140];
seeds = 67;

%% Load partitions
%[hdr,sc159] = niak_read_vol([path_data 'networks_sci180_scg162_scf159.nii.gz']);
[hdr,sc159] = niak_read_vol([path_data 'networks_sci95_scg86_scf86.nii.gz']);
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
pce = niak_lvec2mat(glm.pce);
pce = pce(part == 8, seeds);
