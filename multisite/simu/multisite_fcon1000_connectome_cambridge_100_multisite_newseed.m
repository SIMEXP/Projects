% Generate connectomes on the NYU_TRT database for each session independently
%
% WARNING: This script will clear the workspace
%
% Copyright (c) Pierre Bellec, 
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Québec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, preprocessing, pipeline

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

clear 
p=genpath('/usr/local/niak/niak-boss-0.12.13/');
addpath(p);

path_res     = '/data/cisl/cdansereau/multisite/connectomes_multisite_corrseeds/';
file_basc    = '/data/cisl/cdansereau/multisite/networks_corr_template.mnc.gz';
%file_seed    = '/home/danserea/quarantaine/niak-2013-09-10/niak-trunk-1913/template/list_seeds_cambridge_100.csv';
file_seed    = '/home/cdansereau/svn/projects/multisite/new_seed_cambridge_corr.csv';

%% Set the template
niak_gb_vars
files_in.network = file_basc;

%%%%%%%%%%%%
opt_g.min_nb_vol = 50;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
opt_g.filter.session = {'session1'}; % Just grab session 1
%opt_g.filter.run = {'rest'}; % Just grab the "rest" run

%opt_g.exclude_subject = {'SB_30013','SB_30026','SB_30035'};

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Baltimore/fmri_preprocess_05scrubb',opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in = psom_merge_pipeline(files_in,files_in_tmp);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Berlin/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Cambridge/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Newark/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/NewYork_b/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Oxford/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/Queensland/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

files_in_tmp.fmri = niak_grab_fmri_preprocess('/peuplier/database7/multisite/fcon_1000_preprocess/SaintLouis/fmri_preprocess_05scrubb',opt_g).fmri;
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

%% Set the seed
files_in.seeds = file_seed;

%% Pipeline options
opt = struct();
opt.label_network = 'basc';
opt.folder_out = path_res; % Where to store the results
opt.flag_test = false;

%% PSOM options
opt_psom.path_logs = [path_res 'logs' filesep];
opt_psom.max_queued=20;
%% Generate the pipeline
pipeline = niak_pipeline_connectome(files_in,opt); 
