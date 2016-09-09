% script to run basc on dartel images

clear all

% grabbing the stack file
files_in.data.adni.baseline.run = '/home/atam/scratch/adni_dartel/stack_mnc/stack_4d.mnc.gz';

% set the mask
files_in.mask = '/home/atam/scratch/adni_dartel/mask/mask_gm_dartel_adni.mnc.gz';

% set the aal areas template
files_in.areas = '/home/atam/scratch/adni_dartel/mask/roi_aal_1_5mm.mnc.gz'; % resampled roi_aal to 1.5 mm

% options
opt.folder_out = '/home/atam/scratch/adni_dartel/basc_20160909/';

opt.region_growing.thre_size = 1000; %  the size of the regions, when they stop growing. A threshold of 1000 mm3 will give about 1000 regions on the grey matter. 
opt.grid_scales = [5:5:15]'; % Search for stable clusters in the range 5 to 15 
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 500; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = true;   % Generate maps/time series at the individual level
opt.flag_mixed = false; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = false;  % Generate maps/time series at the group level

% run the pipeline
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
pipeline = niak_pipeline_stability_rest(files_in,opt); 