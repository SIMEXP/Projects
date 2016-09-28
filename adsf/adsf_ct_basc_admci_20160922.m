% a BASC to generate cortical thickness networks on the admci sample
% participants with failed QC were not included in the .mat file

clear all

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.3'))
addpath(genpath('/gs/scratch/atam/tmp')) % to point to quick fix for niak_brick_stability_tseries

path = '/gs/project/gsf-624-aa/database2/adnet/civet_20160913/thickness_files_vertex/';
in.data = [path 'admci_civet_vertex_20160916.mat']; % .mat file containing vertex-based cortical thickness measures for each subject
opt.name_data = 'ct'; % select the correct variable from .mat
opt.folder_out = '/home/atam/scratch/ct_subtypes/admci_basc_ct_20160922/';
opt.scale_grid = [5:1:10 15:5:30]; % make networks with 5 to 30 parcels, with variable steps
pipeline = niak_pipeline_stability_surf(in,opt);