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
%   PART (vector)
%       PART(I) = J if the object I is in the class J.
%       See also: niak_threshold_hierarchy
%
% FILES_OUT
%   (structure) with the following fields:
%   
%   MAP (string, default 'sub_map_%d.png') path to the png visualization of 
%       the subtype maps
%
%   TTEST (string, default 'ttest_%d.png') path to the png visulization of
%       the ttest maps
%
%   MEAN_EFF (string, default 'mean_eff.png') path to...
%
%   GD_MEAN (string, default 'gd_mean.png') path to...
%
%   GD_STD (string, default 'gd_std.png') path to...

end

