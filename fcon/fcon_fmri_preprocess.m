function [pipeline] = fcon_fmri_preprocess(process_list,infos,folder_out,opt)

% Creates an fmri preprocessing pipeline with specified options.
% 
% [pipeline] = fcon_fmri_preprocess(process_list,infos,folder_out,opt)
%
% IN: 
%   process_list:
%     Processing list in form of structure, see niak_pipeline_fmri_preprocess for more information.
%   infos:
%     Information matrix, see fcon_get_infos for more information.
%   folder_out:
%     Folder where to place all the preprocessed files, if it doesn't exist, it will be created.
%   opt:
%     Structure containing more options for fmri preprocess and flag_test.
%
% OUT:
%   pipeline:
%     Pipeline which can be executed using psom_run_pipeline.
%

if ~exist(folder_out,'dir')
  system(['mkdir ' folder_out]);
  warning(['Folder ' folder_out 'not found, created a new one.']);
end

gb_name_structure = 'opt';
gb_list_fields = {'flag_test','flag_siemens'};
gb_list_defaults = {1,0};
niak_set_defaults;

opt.fmri.flag_test = opt.flag_test;

opt.fmri.folder_out = folder_out;
opt.fmri.size_output = 'quality_control';
opt.fmri.motion_correction.flag_skip = false; 
opt.fmri.motion_correction.suppress_vol = infos{3}; 
opt.fmri.time_filter.hp = 0.01;
opt.fmri.time_filter.lp = Inf;
opt.fmri.corsica.flag_skip = 0;
opt.fmri.corsica.sica.nb_comp = 50;
opt.fmri.corsica.threshold = 0.15;
opt.fmri.resample_vol.voxel_size = 3;
opt.fmri.smooth_vol.fwhm = 6;

if infos{6} == 0
  delay = 0;
else
  delay_str = strrep(infos{6},',','.');
  delay = str2double(delay_str);
end

if (strcmp(infos{2},'3T'))
  opt.fmri.t1_preprocess.nu_correct.arg = '-distance 50';
elseif (strcmp(infos{2},'1.5T'))
  opt.fmri.t1_preprocess.nu_correct.arg = '-distance 200';
else
  opt.fmri.t1_preprocess.nu_correct.arg = '-distance 125';
end

opt.slice_timing.delay_in_tr = delay;
if opt.flag_siemens
    opt.fmri.slice_timing.type_scanner = 'Siemens';
else
    opt.fmri.slice_timing.type_scanner = '';
end
opt.fmri.slice_timing.type_acquisition = infos{7};

pipeline = niak_pipeline_fmri_preprocess(process_list,opt.fmri);
