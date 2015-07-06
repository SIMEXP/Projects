clear

%% This script shows how to extract the beta values, the std of beta  and the significance for a number of connections
%% from the results of the glm_connectome pipeline.
%%
%% This script will download and extract some data in the current folder, if it can't find a number of datasets.
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder
%% If the script is executed multiple times, it is supposed to download the data only once. 
%% Erase the content of the folder to start from scratch.

%% for adnet

% this will write a csv for one seed of interest

%% Parameters
path_data = '/home/pbellec/database/adnet/adnet_main_results/';
seed = 10; % select seed of interest
scale = 'sci35_scg35_scf33'; % select scale
list_contrast = { 'ctrlvsmci' , 'avg_ctrl' , 'avg_mci' }; % list the contrasts of interest
list_site = { 'pooled' , 'adni2' , 'criugmmci' , 'adpd' , 'mnimci' }; % list of the sites.

%% First read the networks and find a few significant seeds
[hdr,netwk] = niak_read_vol([path_data 'glm30b_' list_site{1} '_' scale filesep 'networks_' scale '.nii.gz']);
[hdr,tmap1] = niak_read_vol([[path_data 'glm30b_' list_site{1} '_' scale filesep list_contrast{1} filesep 'fdr_' list_contrast{1} '_' scale '.nii.gz']);
list_sig = unique(netwk((tmap1(:,:,:,seed)~=0))); %| (tmap2(:,:,:,seed)~=0) | (tmap3(:,:,:,seed)~=0)));  % conditions for list_sig; can also do list_sig = unique(netwk((tmap1(:,:,:,7)~=0)&(tmap2(:,:,:,7)~=0)));

for num_c = 1:length(list_contrast)
    contrast = list_contrast{num_c};
end

%% Extract the info for each contrast

tab = zeros([(length(list_sig)*length(contrast)) 3]);

for i = 1:length(contrast)
ly = { 'eff' , 'std_eff' , 'sig' };
file = strcat(pwd,filesep,'glm30b_20141216_nii',filesep,scale,filesep,contrast{i},filesep,'glm_',contrast{i},'_',scale,'.mat');
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
    labels_connection{bb} = strcat(contrast{i},(sprintf('_netwk_%i_x_%i',seed,list_sig(ss))));
end

end


%% write the info
file_write = [pwd filesep 'glm30b_20141216_nii' filesep scale filesep 'glm30b_10_eff_connections.csv'];
opt_w.labels_x = labels_connection;
opt_w.labels_y = ly;
niak_write_csv(file_write,tab,opt_w);


