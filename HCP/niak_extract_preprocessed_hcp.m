function files = niak_extract_preprocessed_hcp(path_data,opt)
% Extract files preprocessed by HCP Pipelines, and format then in niak like structure 
%
% SYNTAX:
% FILES = NIAK_EXTRACT_PREPROCESSED_HCP(PATH_DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DATA
%   (string, default ['..'filesep], aka '../') the full path to the outputs of 
%   HCP Preprocessed data (wraning: don't put the output folders in the same directory as the input folders). 
%
% OPT
%   (structure, optional) with the following fields :
%
%   TYPE_TASK
%       (string, default 'MOTOR') type of tasks that would be extracted. Possibles tasks are: 'EMOTION',
%       'GAMBLING','LANGUAGE','MOTOR','REST','RELATIONAL','SOCIAL','WM'.
%
%   PATH_OUT
%       (string, default [pwd filesep], aka './') full path to the outputs of rearranged data
%
%   COPY_OUT
%       (string, default 'LINK') make a synbolic link or a copy of the grabbed data. Possibles options are :
%       'LINK' or 'COPY'.
%
%   MAX_TRANSLATION
%       (scalar, default Inf) the maximal transition (difference between two
%       adjacent volumes) in translation motion parameters within-run (in 
%       mm). The Inf parameter result in selecting all subjects. Motion is 
%       usually addressed by scrubbing (see MIN_NB_VOL below). 
%
%   MAX_ROTATION
%       (scalar, default Inf) the maximal transition (difference between two
%       adjacent volumes) in rotation motion parameters within-run (in 
%       degrees). The Inf parameter result in selecting all subjects. Motion is 
%       usually addressed by scrubbing (see MIN_NB_VOL below). 
%
%   MIN_XCORR_FUNC
%       (scalar, default 0.5) the minimal accceptable XCORR measure of
%       spatial correlation between the individual mean functional volume 
%       in non-linear stereotaxic space and the population average.
%
% _________________________________________________________________________
% OUTPUTS:
%
% FILES
%   (structure) the exact fields depend on OPT.TYPE_TASK. 
%
%   case 'rest' :
%
%       DATA.(SUBJECT).(SESSION).(RUN)
%           (string) preprocessed fMRI datasets. 
%
%       MASK
%           (string) a file name of a binary mask common 
%           to all subjects and runs. The mask is the file located in 
%           quality_control/group_coregistration/anat_mask_group_stereonl.<
%           ext>
%
%       AREAS
%           (string) a file name of an AAL parcelation into anatomical regions
%           resampled at the same resolution as the fMRI datasets. 
% _________________________________________________________________________
% COMMENTS:
%
% This "data grabber" is designed to work with HCP preprocessed data
%
% Copyright (c) Yasssine Benhajali, Pierre Bellec
%               Centre de recherche de l'institut de Gériatrie de Montréal,
%               Département d'informatique et de recherche opérationnelle,
%               Université de Montréal, 2011-2014.
% Maintainer : yassine.ben.haj.ali@umontreal.ca
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : HCP, fMRI,  Preprocessed Data
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

%% Default path for the database
if (nargin<1)||isempty(path_data)
    path_data = [pwd filesep];
end

if ~strcmp(path_data(end),filesep)
    path_data = [path_data filesep];
end

%% Default options
list_fields   = { 'type_task' , 'path_out'     , 'copy_out' };
list_defaults = { 'MOTOR'     , ['..' filesep] , 'link'     };
if nargin > 1
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end

% copy or link option
if opt.copy_out == 'link'
   cp_opt = 'ln -s';
elseif opt.copy_out == 'copy'
   cp_opt = 'cp';
else
   error('%s is an unsupported type of copy options, opt.copy_out should be "copy" or "link" ',opt.copy_out)
end

%% create the output folder structure
fmri_preprocess      = [opt.path_out 'fmri_preprocess_' opt.type_task];
anat                 = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'anat'];
fmri                 = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'fmri'];
quality_control      = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'quality_control'];
group_coregistration = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'quality_control' filesep 'group_coregistration'];
group_motion         = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'quality_control' filesep 'group_motion'];
EVs                  = [opt.path_out 'fmri_preprocess_' opt.type_task  filesep 'EVs'];

mkdir(fmri_preprocess);
mkdir(anat);
mkdir(fmri);
mkdir(quality_control);
mkdir(group_coregistration);
mkdir(group_motion);
mkdir(EVs);

%% Extract necessary files and format them in a NIAK like fmri preprocessed ouput folders and files
% Read subjects list
list_subject = dir(path_data);
list_subject = {list_subject(3:end).name};

% loop over subject and extract files
for nn = 1:length(list_subject)
    subject_raw = strtrim(list_subject{nn}); % original subject name
    subject = ['HCP' subject_raw] ; % formated subject ID wtih a 'HCP' prefix
    mkdir([anat filesep subject]);
    mkdir([EVs filesep subject]);
    mkdir([quality_control filesep subject]);
    % copy the subject anat file (ex: 100307/MNINonLinear/T1w.nii.gz)
    system([cp_opt ' ' subject_raw filesep 'MNINonLinear/T1w.nii.gz ' anat filesep subject filesep 'anat_' subject '_nuc_stereonl.nii.gz']);
    % copy the subject anat mask file (ex :100307/MNINonLinear/brainmask_fs.nii.gz)
    system([cp_opt ' ' subject_raw filesep 'MNINonLinear/brainmask_fs.nii.gz ' anat filesep subject filesep 'anat_' subject '_mask_stereonl.nii.gz']);
    % collect mask files to create an average anat mask
    mask_anat = [subject_raw filesep 'MNINonLinear/brainmask_fs.nii.gz'];
    [hdr,mask] = niak_read_vol(mask_anat);
    if nn == 1
        mask_anat_avg = mask;
    else
        mask_anat_avg = mask + mask_anat_avg;
    end 
    % copy the subject functional file (ex :100307/MNINonLinear/Results/tfMRI_MOTOR_LR/tfMRI_MOTOR_LR.nii.gz) for each run
    system([cp_opt ' ' subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/tfMRI_' opt.type_task '_LR.nii.gz ' fmri filesep 'fmri_' subject '_session1_run1.nii.gz']);
    system([cp_opt ' ' subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_RL/tfMRI_' opt.type_task '_RL.nii.gz ' fmri filesep 'fmri_' subject '_session1_run2.nii.gz']);
    
    % create a mean volumes for run1 and save it in anat folder as  func_HCP<subj>_mean_stereonl.nii.gz
    %
    %to be completed
    
    % copy the subject functional mask file (ex: 100307/100307_tfMRI_MOTOR_preproc/MNINonLinear/Results/tfMRI_MOTOR_LR/brainmask_fs.2.nii.gz)
    system([cp_opt ' ' subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/brainmask_fs.2.nii.gz ' anat filesep subject filesep 'func_' subject '_mask_stereonl.nii.gz']);
    % collect mask files to create an average func mask
    mask_func = [subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/brainmask_fs.2.nii.gz'];
    [hdr,mask] = niak_read_vol(mask_func);
    if nn == 1
        mask_func_avg = mask;
    else
        mask_func_avg = mask + mask_func_avg;
    end
    %reate a qc_motion_group.csv  file that contain 3 colomn: "", "max_rotation" ,"max_translation" for each subject
    % create a fake qc_scrubing_group.csv that contain 5 colomn: "","frames_scrubbed" ,"frames_OK" ,"FD" ,"FD_scrubbed" for each subject and fill it with 0
    %put these file in /quality_control/group_motion
    if nn == 1
       motion_csv = cell(length(list_subject)+1,3);
       scrub_csv  = cell(length(list_subject)*2+1,5); % for the scrubbing there is two runs to be written down in the csv file 
       xcorrf_csv = cell(length(list_subject)+1,3);
       xcorra_csv = cell(length(list_subject)+1,3);
       
       motion_csv(1,:) = { '' , 'max_rotation' , 'max_translation' };
       scrub_csv(1,:)  = { '' , 'frames_scrubbed' ,'frames_OK' ,'FD' ,'FD_scrubbed' };
       xcorrf_csv(1,:) = { '' , 'perc_overlap_mask' ,'xcorr_vol' };
       xcorra_csv(1,:) = { '' , 'perc_overlap_mask' ,'xcorr_vol' };
       
       motion_csv(nn+1,:) = { subject, ones, ones };
       scrub_csv(nn+1,:)  = { [subject '_session1_run1'], ones, ones*100, ones, ones };
       scrub_csv(nn+2,:)  = { [subject '_session1_run2'], ones, ones*100, ones, ones };
       xcorrf_csv(nn+1,:) = { subject, ones, ones };
       xcorra_csv(nn+1,:) = { subject, ones, ones };
       inc = 0;
    else
       inc = inc+1;
       motion_csv(nn+1,:)    = { subject, ones, ones };
       scrub_csv(nn+inc+1,:) = { [subject '_session1_run1'], ones, ones*100, ones, ones };
       scrub_csv(nn+inc+2,:) = { [subject '_session1_run2'], ones, ones*100, ones, ones };
       xcorrf_csv(nn+1,:)    = { subject, ones, ones };
       xcorra_csv(nn+1,:)    = { subject, ones, ones };
    end
    % copy the subject onset file (ex: 100307/MNINonLinear/Results/tfMRI_EMOTION_LR/EVs/ (fear.txt, neut.txt, Stats.txt, Sync.txt)
    system(['cp ' subject_raw filesep 'MNINonLinear/Results/tfMRI_MOTOR_LR/EVs/* ' EVs filesep subject filesep '.']);
end

%create an average anat and func mask
mask_anat_avg = mask_anat_avg/length(list_subject);
mask_func_avg = mask_func_avg/length(list_subject);
mask_group_anat = mask_anat_avg > 0.5;
mask_group_func = mask_func_avg > 0.5;

% save the functional and the anat group mask
hdr.file_name = [ group_coregistration filesep 'anat_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr,mask_group_anat);
hdr.file_name = [ group_coregistration filesep 'func_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr,mask_group_func);

% save the csv motion,xcorr func  and scrubbing files
niak_write_csv_cell ([ group_motion filesep 'qc_motion_group.csv' ], motion_csv );
niak_write_csv_cell ([ group_motion filesep 'qc_scrubbing_group.csv' ], scrub_csv );
niak_write_csv_cell ([ group_coregistration filesep 'func_tab_qc_coregister_stereonl.csv' ], xcorrf_csv );
niak_write_csv_cell ([ group_coregistration filesep 'anat_tab_qc_coregister_stereonl.csv' ], xcorrf_csv );

% get the the AAL template from github and save it 
[msg,err]=system(['wget -O ' anat filesep 'template_aal.mnc.gz https://github.com/SIMEXP/niak/raw/master/template/roi_aal_3mm.mnc.gz']);
