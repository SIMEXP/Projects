% Template for the HCP CONNECTOME pipeline
%
% To run this pipeline, the fMRI datasets first need to be preprocessed 
% using the NIAK fMRI preprocessing pipeline, and a set of functional 
% parcelations have to be generated using the BASC pipeline. 
%
% WARNING: This script will clear the workspace
%
% Copyright (c) Pierre Bellec, 
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Qubec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, preprocessing, pipeline
%
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

clear all
%addpath(genpath('/usr/local/niak/niak-boss-0.12.13')) %magma 
path_root =  '/home/yassinebha/database/HCP/';
%% Set the template
niak_gb_vars
files_in.network = [ gb_niak_path_template 'basc_cambridge_sc100.mnc.gz' ];

% Resample the 3mm cambridge template to 2mm
files_in_resamp.source =   files_in.network;
files_in_resamp.target = [ path_root 'fmri_preprocess_MOTOR_hcp/anat/template_aal.mnc.gz' ];
files_out_resamp       =  [ path_root 'fmri_preprocess_MOTOR_hcp/anat/basc_cambridge_sc100_2mm.mnc.gz' ];
opt_resamp.interpolation  = 'nearest_neighbour';
niak_brick_resample_vol (files_in_resamp,files_out_resamp,opt_resamp);
files_in.network = files_out_resamp;

%% Grabbing the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 1;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'roi';
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
%opt_g.filter.session = {'session1'}; % Just grab session 1
%opt_g.filter.run = {'rest'}; % Just grab the "rest" run
files_in.fmri = niak_grab_fmri_preprocess([path_root 'fmri_preprocess_MOTOR_hcp'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%% Set the seeds
files_in.seeds = [ gb_niak_path_template 'list_seeds_cambridge_100_full.csv'];

%% Options 
opt.folder_out = [ path_root 'connectome_MOTOR_hcp']; % Where to store the results
opt.connectome.type = 'Z'; % The type of connectome. See "help niak_brick_connectome" for more info. 
% 'S': covariance; 
%'R': correlation; 
%'Z': Fisher transform of the correlation; 
%'U': concentration; 
%'P': partial correlation.
opt.connectome.thresh.type = 'sparsity_pos'; % The type of treshold used to binarize the connectome. See "help niak_brick_connectome" for more info. 
% 'sparsity': keep a proportion of the largest connection (in absolute value); 
% 'sparsity_pos' keep a proportion of the largest connection (positive only)
% 'cut_off' a cut-off on connectivity (in absolute value)
% 'cut_off_pos' a cut-off on connectivity (only positive) 
opt.connectome.thresh.param = 0.2; % the parameter of the thresholding. The actual definition depends of THRESH.TYPE:
% 'sparsity' (scalar, default 0.2) percentage of connections
% 'sparsity_pos' (scalar, default 0.2) percentage of connections
% 'cut_off' (scalar, default 0.25) the cut-off
% 'cut_off_pos' (scalar, default 0.25) the cut-off       

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the pipeline will start. 
%opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_connectome(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '/.']); % make a copie of this script to output folder
