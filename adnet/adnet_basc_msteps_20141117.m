
clear all

addpath(genpath('/home/atam/quarantaine/niak-boss-0.12.18'));

path_data = '/home/atam/database/';

files_in = niak_grab_region_growing([path_data 'adnet/region_growing_20140507/rois/']);
 
%%%%%%%%%%%%%%%%%%%%%

files_in.infos = [path_data 'adnet/models/adnet_model_group_20141031.csv']; % A file of comma-separeted values describing additional information on the subjects, this can be omitted

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.folder_out = [path_data 'adnet/basc_msteps_20141117/']; % Where to store the results
opt.grid_scales = 5:5:200; % Search for stable clusters in the range 10 to 500
% opt.scales_maps = repmat(opt.grid_scales,[1 3]); % The scales that will be used to generate the maps of brain clusters and stability. 
%                                                  % In this example the same number of clusters are used at the individual (first column), 
%                                                  % group (second column) and consensus (third and last colum) levels.
opt.scales_maps = [5 4 4;...
5 6 6;...
10 8 8;...
15 17 18;...
45 32 32;...
70 63 66;...
135 122 120;...
180 216 218];
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 1000; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = false;   % Generate maps/time series at the individual level
opt.flag_mixed = false; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true;  % Generate maps/time series at the group level

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
opt.psom.qsub_options= '-A gsf-624-aa -q sw -l nodes=1:ppn=2 -l walltime=30:00:00';
%opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
pipeline = niak_pipeline_stability_rest(files_in,opt); 
