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

%% build the average group connectome
scale = 'sci10_scg10_scf10'; % select scale
contrast = 'szVScont_age_sex_FD'; % list the contrasts of interest
list_connection = [ 9 5 ;
                    9 7 ]; % list the connections. Each line is a pair of networks, 
                           % and networks are labeled based on the file networks_sci10_scg10_scf10.nii.gz
labels_connection = { 'PCC_x_aDMN' ;
                      'PCC_x_sensorimotor'   }; % Labels for the connections. This has to be defined manually
%% Extract the info
ly = { 'eff' , 'std_eff' , 'sig' };
tab = zeros([length(labels_connection) 3]);
file = [pwd filesep 'cobre_glm_connectome_nii' filesep scale filesep contrast filesep 'glm_' contrast '_' scale '.mat'];
data = load(file);
eff = niak_lvec2mat(data.eff);
std_eff = niak_lvec2mat(data.std_eff);
test_q = data.test_q;

for cc = 1:length(labels_connection)
    tab(cc,1) = eff(list_connection(cc,1),list_connection(cc,2));
    tab(cc,2) = std_eff(list_connection(cc,1),list_connection(cc,2));
    tab(cc,3) = test_q(list_connection(cc,1),list_connection(cc,2));
end

%% write the info
file_write = 'eff_connections.csv';
opt_w.labels_x = labels_connection;
opt_w.labels_y = ly;
niak_write_csv(file_write,tab,opt_w);