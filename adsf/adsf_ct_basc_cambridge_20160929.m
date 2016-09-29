% a BASC to generate cortical thickness networks on the cambridge sample
% participants with failed QC were not included in the .mat file

clear all

addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.3'))
addpath(genpath('/gs/scratch/atam/tmp')) % to point to quick fix for niak_brick_stability_tseries

path = '/home/atam/scratch/ct_subtypes/cambridge/cambridge_civet/thickness_vertex/';
in.data = [path 'cambridge_civet_vertex_20160929.mat']; % .mat file containing vertex-based cortical thickness measures for each subject
opt.name_data = 'ct'; % select the correct variable from .mat
opt.folder_out = '/home/atam/scratch/ct_subtypes/cambridge_basc_ct_20160929/';
opt.scale_grid = [5:1:10 15:5:30]; % make networks with 5 to 30 parcels, with variable steps
pipeline = niak_pipeline_stability_surf(in,opt);