clear

%% This script shows how to extract the beta values and the significance for a number of connections
%% from the results of the glm_connectome pipeline.
%%
%% This script will download and extract some data in the current folder, if it can't find a number of datasets.
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder
%% If the script is executed multiple times, it is supposed to download the data only once. 
%% Erase the content of the folder to start from scratch.

%% for adnet

% this will write a csv for one seed of interest

%% add niak path
addpath(genpath('/usr/local/quarantine/niak-boss-0.12.14'))

%% Select the scale and contrast
scale = 'sci65_scg65_scf65'; % select scale
contrast = {'avg_ctrl','avg_ad','avg_mci','ctrlvsmci','ctrlvsad','mcivsad'}; % list the contrasts of interest
contrast1 = 'ctrlvsmci'; % specify contrasts
contrast2 = 'ctrlvsad';
contrast3 = 'mcivsad';

%% First read the networks and find a few significant seeds
[hdr,netwk] = niak_read_vol([pwd filesep 'glm17d_nii' filesep scale filesep 'networks_' scale '.nii.gz']);
[hdr,tmap1] = niak_read_vol([pwd filesep 'glm17d_nii' filesep scale filesep contrast1 filesep 'fdr_' contrast1 '_' scale '.nii.gz']);
[hdr,tmap2] = niak_read_vol([pwd filesep 'glm17d_nii' filesep scale filesep contrast2 filesep 'fdr_' contrast2 '_' scale '.nii.gz']);
[hdr,tmap3] = niak_read_vol([pwd filesep 'glm17d_nii' filesep scale filesep contrast3 filesep 'fdr_' contrast3 '_' scale '.nii.gz']); 
seed = 55; % select seed of interest
list_sig = unique(netwk((tmap1(:,:,:,seed)~=0) | (tmap2(:,:,:,seed)~=0) | (tmap3(:,:,:,seed)~=0)));  % conditions for list_sig; can also do list_sig = unique(netwk((tmap1(:,:,:,7)~=0)&(tmap2(:,:,:,7)~=0)));

%% Extract the info for each contrast

tab = zeros([(length(list_sig)*length(contrast)) 3]);

for i = 1:length(contrast)
ly = { 'eff' , 'std_eff' , 'sig' };
file = strcat(pwd,filesep,'glm17d_nii',filesep,scale,filesep,contrast{i},filesep,'glm_',contrast{i},'_',scale,'.mat');
data = load(file);
eff = niak_lvec2mat(data.eff);
std_eff = niak_lvec2mat(data.std_eff);
test_q = data.test_q;

for ss = 1:length(list_sig)
    cc = length(list_sig);
    bb = (cc.*(i-1)+ss);
    tab(bb,1) = eff(seed,list_sig(ss));
    tab(bb,2) = std_eff(seed,list_sig(ss));
    tab(bb,3) = test_q(seed,list_sig(ss));
    labels_connection{bb} = strcat((sprintf('netwk_%i_x_%i',seed,list_sig(ss))),'_',contrast{i});
end

end


%% write the info
file_write = 'glm17d_55_eff_connections.csv';
opt_w.labels_x = labels_connection;
opt_w.labels_y = ly;
niak_write_csv(file_write,tab,opt_w);


