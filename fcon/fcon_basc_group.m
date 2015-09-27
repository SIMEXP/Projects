function [pipeline] = fcon_basc_group(subjects,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_TEMPLATE_BASC_GROUP
%
%   Creates the pipeline to run basc processing. 
% 
%   [pipeline] = fcon_basc_group(subjects,opt)
%   
%   subjects: list of subjects with genders, see fcon_read_demog.
%   opt:structure containing:
%     path_database: path to the database.
%     path_output: path where output from basc is saved.
%     path_mask: path to mask to use.
%     path_areas: path to areas to use.
%     path_logs: path where to save the log files.
%     path_search: path to search (default '').
%     max_func: maximum number of func files to use (default Inf).
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, slice timing, fMRI

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gb_name_structure = 'opt';
gb_list_fields = {'path_database','path_output','path_mask','path_areas','path_logs','path_search','max_func'};
gb_list_defaults = {NaN,NaN,NaN,NaN,NaN,'',Inf};
niak_set_defaults;

if ~exist(opt.path_database,'dir')
    error(['Path to database ' opt.path_database ' does not exist.']);
end
if ~exist(opt.path_output,'dir')
    warning(['Output path ' opt.path_output ' did not exist, created one.']);
    system(['mkdir ' opt.path_output]);
end
if ~exist(opt.path_mask,'file')
    error(['Mask ' opt.path_mask ' not found.']);
end
if ~exist(opt.path_areas,'file')
    error(['Areas ' opt.path_areas ' not found.']);
end
if ~exist(opt.path_logs,'dir')
    warning(['Logs path ' opt.path_logs ' does not exist, creating one.']);
    system(['mkdir ' opt.path_logs]);
end

opt_files.path_database = opt.path_database;
opt_files.max_func = opt.max_func;
files_in = fcon_basc_get_files(subjects,opt_files);

%% Functional mask
files_in.mask = opt.path_mask; % That's a mask for the analysis. It can be a mask of the brain common to all subjects, or a mask of a specific brain area, e.g. the thalami.

%% Functional areas
files_in.areas = opt.path_areas; % That's a mask a brain areas that is used to save memory space in the region-growing algorithm. Different brain areas are treated independently at this step of the analysis. If the mask is small enough, this may not be necessary. In this case, use the same file as MASK here.

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

%% Size of rois for the region-growing algorithm
opt_basc.size_rois = 1000; % For a full brain analysis

%% Block length in the circular block bootstrap of individual fMRI time
%% series
opt_basc.block_length = [5:15]; % The time series would have 100 time points

%% Number of bootstrap samples for the individual stability analysis (first
%% pass/second pass)
opt_basc.nb_samps_ind = [30 100]; % Go fast in the first pass and be accurate in the second pass. 

%% Number of bootstrap samples for the group stability analysis (first
%% pass/second pass)
opt_basc.nb_samps_group = [50 1000]; % Go fast in the first pass and be accurate in the second pass. 

%% Group-level scales to explore in the first pass (the individual scales
%% are picked up in a neighbourhood of the group scale, and every possible
%% final scale is tested
opt_basc.list_scales_pass1 = [5 7 9 11 13 15 17 20 23 26 30]; % Search in the range 5-30 clusters

%% The individual/group/final number of clusters for the second pass where
%% stability maps are actually generated. Note that multiple rows can be
%% specified to test more than one scale. 
opt_basc.list_scales_pass2 = [8 6 6 ; 13 10 10]; % The final clustering parameters (individual, group and final)

%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%

opt_basc.folder_out = opt.path_output; % Where to store the results
opt_basc.psom.path_search = opt.path_search;
opt_basc.psom.path_logs = opt.path_logs;
opt_basc.flag_test = 1;
%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

pipeline = niak_pipeline_basc_group(files_in,opt_basc); 
