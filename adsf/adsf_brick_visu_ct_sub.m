function [files_in,files_out,opt] = adsf_visu_ct_subtype(files_in,files_out,opt)
% Function to visualize cortical thickness subtypes
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = ADSF_VISU_CT_SUBTYPE(FILES_IN,FILES_OUT,OPT)
% _________________________________________________________________________
% 
% INPUTS:
% 
% FILES_IN 
%   (string) path to a .mat file containing the following variable:
%
%   SUB (structure) with the following fields:
%       MAP, TTEST, MEAN_EFF, GD_MEAN, GD_STD
%
% FILES_OUT
%   (structure) with the following fields:
%   
%   MAP (cell array, default 'sub_map_%d.png') path to the png visualization of 
%       the subtype maps
%
%   TTEST (cell array, default 'ttest_%d.png') path to the png visulization of
%       the ttest maps
%
%   MEAN_EFF (cell array, default 'mean_eff.png') path to...
%
%   GD_MEAN (string, default 'gd_mean.png') path to...
%
%   GD_STD (string, default 'gd_std.png') path to...
%
% OPT
%   (structure) with the following fields:
%
%   FOLDER_OUT
%       (string, default '') if not empty, this specifies the path where
%       outputs are generated
%
%   NB_SUBTYPE
%       (integer) number of subtypes
%
%   FLAG_VERBOSE
%       (boolean, default true) turn on/off the verbose.
%
%   FLAG_TEST
%       (boolean, default false) if the flag is true, the brick does not do 
%       anything but updating the values of FILES_IN, FILES_OUT and OPT.

%% Initialization and syntax checks

% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SUBTYPING(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_subtyping'' for more info.')
end

% Input
if ~ischar(files_in)
    error('niak:brick','FILES_IN must be a string')
end

% Options
if nargin < 3
    opt = struct;
end

opt = psom_struct_defaults(opt,...
      { 'folder_out',  'nb_subtype',  'flag_verbose' , 'flag_test' },...
      { ''          ,  NaN         ,  true           , false       });

% FILES_OUT
if ~isempty(opt.folder_out)
    path_out = niak_full_path(opt.folder_out);
    files_out = psom_struct_defaults(files_out,...
                { 'map'                                                   , 'ttest'                                               , 'mean_eff'                                                , 'gd_mean'               , 'gd_std'                },...
                { make_paths(path_out, 'sub_map_%d.png', 1:opt.nb_subtype), make_paths(path_out, 'ttest_%d.png', 1:opt.nb_subtype),  make_paths(path_out, 'mean_eff_%d.png', 1:opt.nb_subtype), [path_out 'gd_mean.png'], [path_out 'gd_std.png'] });
else
    files_out = psom_struct_defaults(files_out,...
                { 'map'            , 'ttest'          , 'mean_eff'       , 'gd_mean'        , 'gd_std'         },...
                { 'gb_niak_omitted', 'gb_niak_omitted', 'gb_niak_omitted', 'gb_niak_omitted', 'gb_niak_omitted'});
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Brick starts here

% Load files_in
data = load(files_in);
subt = data.sub.map;
subt_ttest = data.sub.ttest;
mean_eff = data.sub.mean_eff;
gd_mean = data.sub.gd_mean;
gd_std = data.sub.gd_std;

% Load surface
ssurf = niak_read_surf;

% Make a figure for each subtype
for ss = 1:opt.nb_subtype
    % Start with the figure
    fh = figure('Visible', 'off');
    opt_s.colormap = 'gray_hot_cold';
    opt_s.limit = [-0.2 0.2];
    adsf_visu_surf(subt(ss,:),ssurf,opt_s);
    if ~strcmp(files_out.map, 'gb_niak_omitted')
        print(fh, files_out.map{ss}, '-r300', '-dpng');
    end
end

% Make a figure for each ttest
for ss = 1:opt.nb_subtype
    % Start with the figure
    fh = figure('Visible', 'off');
    opt_t.colormap = 'gray_hot_cold';
    opt_t.limit = [-8 8];
    adsf_visu_surf(subt_ttest(ss,:),ssurf,opt_t);
    if ~strcmp(files_out.ttest, 'gb_niak_omitted')
        print(fh, files_out.ttest{ss}, '-r300', '-dpng');
    end
end

% Make a figure for each mean_eff
for ss = 1:opt.nb_subtype
    % Start with the figure
    fh = figure('Visible', 'off');
    opt_e.colormap = 'gray_hot_cold';
    opt_e.limit = [-0.3 0.3];
    adsf_visu_surf(mean_eff(ss,:),ssurf,opt_e);
    if ~strcmp(files_out.mean_eff, 'gb_niak_omitted')
        print(fh, files_out.mean_eff{ss}, '-r300', '-dpng');
    end
end

% Make figure for gd_mean
fh = figure('Visible', 'off');
opt_g.colormap = 'gray_hot_cold';
adsf_visu_surf(gd_mean,ssurf,opt_g);
if ~strcmp(files_out.gd_mean, 'gb_niak_omitted')
    print(fh, files_out.gd_mean, '-r300', '-dpng');
end

% Make figure for gd_std
fh = figure('Visible', 'off');
adsf_visu_surf(gd_std,ssurf,opt_g);
if ~strcmp(files_out.gd_std, 'gb_niak_omitted')
    print(fh, files_out.gd_std, '-r300', '-dpng');
end
end

function path_array = make_paths(out_path, template, scales)
    % Get the number of networks
    n_networks = length(scales);
    path_array = cell(n_networks, 1);
    for sc_id = 1:n_networks
        sc = scales(sc_id);
        path = fullfile(out_path, sprintf(template, sc));
        path_array{sc_id, 1} = path;
    end
return
end

