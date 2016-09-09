% script to combine dartel 3d maps into one 4d map

clear all

path_in = '/home/atam/scratch/adni_dartel/raw_mnc/';
path_out = '/home/atam/scratch/adni_dartel/stack_mnc/';
path_model = '/home/atam/scratch/adni_dartel/adni_model_20160906.csv';
ext_v = '.mnc.gz';

stack = adsf_brick_3d_to_4d(path_in,path_out,path_model,ext_v);