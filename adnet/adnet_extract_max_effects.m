clear

%% This script shows how to extract the beta values and the significance for a number of connections
%% from the results of the glm_connectome pipeline.
%%
%% This script will download and extract some data in the current folder, if it can't find a number of datasets.
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder
%% If the script is executed multiple times, it is supposed to download the data only once. 
%% Erase the content of the folder to start from scratch.

% %% Download example time series
% if ~psom_exist('cobre_glm_connectome_nii')
%     system('wget http://www.nitrc.org/frs/download.php/6814/cobre_glm_connectome_nii.zip')
%     system('unzip cobre_glm_connectome_nii.zip')
%     psom_clean('cobre_glm_connectome_nii.zip')
% end     

%% add niak path
addpath(genpath('/usr/local/quarantine/niak-boss-0.12.14'))

%% Load the effect maps and corresponding networks
path_ref  = [pwd filesep];
path_net  = [path_ref 'glm17d_nii' filesep 'sci65_scg65_scf65' filesep];
path_maps = [path_net 'ctrlvsad' filesep];
file_eff  = [path_maps 'effect_ctrlvsad_sci65_scg65_scf65.nii.gz'];
[hdr,eff] = niak_read_vol(file_eff);
file_net  = [path_net 'networks_sci65_scg65_scf65.nii.gz'];
[hdr,net] = niak_read_vol(file_net);

%% Extract max absolute effects
nb_net = max(net(:));
val_max = zeros(nb_net,1);
ind_max = zeros(nb_net,1);
for nn = 1:max(net(:))
    map_eff_net = eff(:,:,:,nn);
    [val,ind] = max(abs(map_eff_net(:)));
    val = val(1);
    ind = ind(1);
    ind_max(nn) = net(ind);
    val_max(nn) = val;
end

%% Generate a .csv summary
[val_max,order] = sort(val_max,'descend');
tab = [order , val_max , ind_max(order)];

opt_csv.labels_y = {'network index' , 'max abs effect' , 'with network index'};
niak_write_csv([path_ref 'adnet_sc65_ctrlvsad_summary_max_eff.csv'],tab,opt_csv);
