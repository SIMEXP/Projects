clear

%% This script shows how to extract the beta values and the significance for a number of connections
%% from the results of the glm_connectome pipeline.
%%
%% This script will download and extract some data in the current folder, if it can't find a number of datasets.
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder
%% If the script is executed multiple times, it is supposed to download the data only once. 
%% Erase the content of the folder to start from scratch.

%% Download example time series
if ~psom_exist('cobre_glm_connectome_nii')
    system('wget http://www.nitrc.org/frs/download.php/6813/cobre_glm_connectome_nii.zip')
    system('unzip cobre_glm_connectome_nii.zip')
    psom_clean('cobre_glm_connectome_nii.zip')
end

%% Select the scale and contrast
scale = 'sci10_scg10_scf10'; % select scale
contrast = 'szVScont_age_sex_FD'; % list the contrasts of interest

%% First read the networks and find a few significant seeds
[hdr,netwk] = niak_read_vol([pwd filesep 'cobre_glm_connectome_nii' filesep scale filesep 'networks_' scale '.nii.gz']);
[hdr,tmap1] = niak_read_vol([pwd filesep 'cobre_glm_connectome_nii' filesep scale filesep contrast filesep 'fdr_' contrast '_' scale '.nii.gz']);
[hdr,tmap2] = niak_read_vol([pwd filesep 'cobre_glm_connectome_nii' filesep scale filesep 'szVScont_age' filesep 'fdr_szVScont_age_' scale '.nii.gz']);
seed = 7; % that's a network numbered as in the file networks_sci10_scg10_scf10.nii.gz
list_sig = unique(netwk((tmap1(:,:,:,7)~=0)&(tmap2(:,:,:,7)~=0)));

%% Extract the info
ly = { 'eff' , 'std_eff' , 'sig' };
tab = zeros([length(labels_connection) 3]);
file = [pwd filesep 'cobre_glm_connectome_nii' filesep scale filesep contrast filesep 'glm_' contrast '_' scale '.mat'];
data = load(file);
eff = niak_lvec2mat(data.eff);
std_eff = niak_lvec2mat(data.std_eff);
test_q = data.test_q;

for ss = 1:length(list_sig)
    tab(ss,1) = eff(seed,list_sig(ss));
    tab(ss,2) = std_eff(seed,list_sig(ss));
    tab(ss,3) = test_q(seed,list_sig(ss));
    labels_connection{ss} = sprintf('netwk_%i_x_%i',seed,list_sig(ss));
end

%% write the info
file_write = 'eff_connections.csv';
opt_w.labels_x = labels_connection;
opt_w.labels_y = ly;
niak_write_csv(file_write,tab,opt_w);
