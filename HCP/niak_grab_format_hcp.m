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
%       (string, default 'motor') type of tasks that would be extracted. Possibles tasks are: 'emotion',
%       'gambling','language','motor','rest','relational','social','wm'.
%
%   PATH_OUT
%       (string, default [pwd filesep], aka './') full path to the outputs of rearranged data
%
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
%
%
%% Default path for the database
if (nargin<1)||isempty(path_data)
    path_data = [pwd filesep];
end

if ~strcmp(path_data(end),filesep)
    path_data = [path_data filesep];
end

%% Default options
list_fields   = { 'type_task' , 'path_out'    };
list_defaults = { 'motor'     , ['..' filesep] };
if nargin > 1
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
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

%% Read subjects list
list_subject = dir(path_data);
list_subject = {list_subject(3:end).name};

%% Extract necessary files and format them in a NIAK like fmri preprocessed ouput folder
for nn = 1:length(list_subject)
    subject = strtrim(list_subject{nn});
    mkdir([anat filesep subject]);
    mkdir([EVs filesep subject]);
    % copy the subject anat file (ex: 100307/MNINonLinear/T1w.nii.gz)
    system(['ln -s ' subject filesep 'MNINonLinear/T1w.nii.gz ' anat filesep subject filesep 'anat_HCP' subject '_nuc_stereonl.nii.gz']);
    % copy the subject anat mask file (ex :100307/MNINonLinear/brainmask_fs.nii.gz)
    system(['ln -s ' subject filesep 'MNINonLinear/brainmask_fs.nii.gz ' anat filesep subject filesep 'anat_HCP' subject '_mask_stereonl.nii.gz']);
    % collect mask files to create an average anat mask
    mask_anat = [subject filesep 'MNINonLinear/brainmask_fs.nii.gz'];
    [hdr,mask] = niak_read_vol(mask_anat);
    if nn == 1
        mask_anat_avg = mask;
    else
        mask_anat_avg = mask + mask_anat_avg;
    end
    % copy the subject functional file (ex :100307/MNINonLinear/Results/tfMRI_MOTOR_LR/tfMRI_MOTOR_LR.nii.gz) for each run
    system(['ln -s ' subject filesep 'MNINonLinear/Results/tfMRI_MOTOR_LR/tfMRI_MOTOR_LR.nii.gz ' fmri filesep 'fmri_HCP' subject '_session1_run1.nii.gz']);
    system(['ln -s ' subject filesep 'MNINonLinear/Results/tfMRI_MOTOR_RL/tfMRI_MOTOR_RL.nii.gz ' fmri filesep 'fmri_HCP' subject '_session1_run2.nii.gz']);
    
    % create a mean volumes for run1 and save it in anat folder as  func_HCP<subj>_mean_stereonl.nii.gz
    %
    %to be completed
    
%      % copy the subject functional mask file (ex: 100307/100307_tfMRI_MOTOR_preproc/MNINonLinear/Results/tfMRI_MOTOR_LR/brainmask_fs.2.nii.gz)
%      system(['cp ' subject filesep subject '_tfMRI_MOTOR_preproc/MNINonLinear/Results/tfMRI_MOTOR_LR/brainmask_fs.2.nii.gz ' anat filesep subject filesep 'func_HCP' subject '_mask_stereonl.nii.gz']);
%      % collect mask files to create an average func mask
%      mask_func = [subject filesep subject '_tfMRI_MOTOR_preproc/MNINonLinear/Results/tfMRI_MOTOR_LR/brainmask_fs.2.nii.gz'];
%      [hdr,mask] = niak_read_vol(mask_func);
%      if nn == 1
%          mask_func_avg = mask;
%      else
%          mask_func_avg = mask + mask_func_avg;
%      end
%     
   % create a qc_motion_group.csv  file that contain 3 colomn: "", "max_rotation" ,"max_translation" for each subject
    % create a fake qc_scrubing_group.csv that contain 5 colomn: "","frames_scrubbed" ,"frames_OK" ,"FD" ,"FD_scrubbed" for each subject and fill it with 0
    %put these file in /quality_control/group_motion
    %to be completed
    if nn == 1
       motion_csv = cell(length(list_subject)+1,3);
       scrub_csv  = cell(length(list_subject)+1,5);
       motion_csv(1,:) = { '' , 'max_rotation' , 'max_translation' };
       scrub_csv(1,:)  = { '' , 'frames_scrubbed' ,'frames_OK' ,'FD' ,'FD_scrubbed' };
       motion_csv(nn+1,:) = { subject, ones, ones };
       scrub_csv(nn+1,:)  = { subject, ones, ones, ones, ones };
    else 
       motion_csv(nn+1,:) = { subject, ones, ones };
       scrub_csv(nn+1,:)  = { subject, ones, ones, ones, ones };
    end
    % copy the subject onset file (ex: 100307/MNINonLinear/Results/tfMRI_EMOTION_LR/EVs/ (fear.txt, neut.txt, Stats.txt, Sync.txt)
    system(['cp ' subject filesep 'MNINonLinear/Results/tfMRI_MOTOR_LR/EVs/* ' EVs filesep subject filesep '.']);
end
%create an average anat and func mask
mask_anat_avg = mask_anat_avg/length(list_subject);
%  mask_func_avg = mask_func_avg/length(list_subject);
% save a group mask
mask_group_anat = mask_anat_avg > 0.5;
%  mask_group_func = mask_func_avg > 0.5;
% save the functional and the anat group mask
hdr.file_name = [ group_coregistration filesep 'anat_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr,mask_group_anat);
hdr.file_name = [ group_coregistration filesep 'func_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr,mask_group_anat);

% save the csv motion and scrubbing files
niak_write_csv_cell ([ group_motion filesep 'qc_motion_group.csv' ], motion_csv );
niak_write_csv_cell ([ group_motion filesep 'qc_scrubbing_group.csv' ], scrub_csv );


list_subject = {'s1','s2',...};

for ss = 1:length(list_subject)
    subject = list_subject{ss};
    file_name = [path_data 'mask_' subject '.nii.gz'];
    [hdr,mask] = niak_read_vol(file_name);
    if ss = 1
        mask_avg = mask;
    else
        mask_avg = mask+mask_avg;
    end
end
mask_avg = mask_avg/length(list_subject);

mask_group = mask_avg > 0.5;

niak_montage(mask_avg);
niak_montrage(mask_group);