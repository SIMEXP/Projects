% a BASC to generate cortical thickness networks

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.3'))

path = '/home/atam/group_database/database2/preventad/thickness_files_bl_vertex_20150831/';
in.data = [path 'preventad_civet_vertex_bl_20160202.mat']; % .mat file containing vertex-based cortical thickness measures for each subject
opt.name_data = 'ct'; % select the correct variable from .mat
opt.folder_out = '/home/atam/scratch/adsf_basc_ct_20160202/';
opt.scale_grid = [5:5:30]; % make networks with 5 to 30 parcels with a step of 5
pipeline = niak_pipeline_stability_surf(in,opt);
