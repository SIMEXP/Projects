function [files_ind,files_group] = niak_extract_preprocessed_hcp(path_data,opt)
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
%   FILE_EXT
%       (string, default 'MINC') The exention for the grabbed files. Possible extention 'NIFTI' or 'MINC'.
%       case minc, data will be converted from nifti to minc.
%       
%
%
% _________________________________________________________________________
% OUTPUTS:
%
% FILES_IND
%   (structure) the exact fields depend on OPT.TYPE_TASK. Case 'EMOTION',
%   'GAMBLING','LANGUAGE','MOTOR','RELATIONAL','SOCIAL','WM':
%
%       (SUBJECT).(SESSION).(RUN)
%           (string) preprocessed fMRI datasets.
%
% FILES_GROUP
%   (structure) the exact fields depend on OPT.TYPE_TASK. 
%       ANAT_MASK
%           (string) a file name of a binary  anatomical mask common 
%           to all subjects and runs. The mask is the file located in 
%           quality_control/group_coregistration/anat_mask_group_stereonl.<
%           ext>
%       FUNC_MASK
%           (string) a file name of a binary  functional mask common 
%           to all subjects and runs. The mask is the file located in 
%           quality_control/group_coregistration/func_mask_group_stereonl.<
%           ext>
%
%       AREAS
%           (string) a file name of an AAL parcelation into anatomical regions
%           resampled at the same resolution as the fMRI datasets. 
%
%       FLAG_VERBOSE 
%           (boolean, default 1) if the flag is 1, then the function prints 
%           some infos during the processing.
%
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
path_data = niak_full_path (path_data);

%% Default options
list_fields   = { 'type_task' , 'path_out'     , 'copy_out' , 'file_ext', 'flag_verbose'};
list_defaults = { 'MOTOR'     , ['..' filesep] , 'link'     , 'minc'    ,  1            };
if nargin > 1
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end
opt.path_out = niak_full_path (opt.path_out);

% copy or link option
if opt.copy_out == 'link'
   cp_opt = 'ln -s';
elseif opt.copy_out == 'copy'
   cp_opt = 'cp';
else
   error('%s is an unsupported type of copy options, opt.copy_out should be "copy" or "link" ',opt.copy_out)
end

% files extension
if opt.file_ext == 'minc'
   ext = 'mnc.gz';
elseif opt.file_ext == 'nifti'
   ext = 'nii.gz';
else 
   error('%s is an unsupported type of extention option, opt.file_ext should be "minc" or "nifti" ',opt.file_ext)
end
%% create the output folder structure
opt.type_task = upper(opt.type_task);
fmri_preprocess      = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'];
anat                 = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'anat'];
fmri                 = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'fmri'];
quality_control      = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'quality_control'];
group_coregistration = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'quality_control' filesep 'group_coregistration'];
group_motion         = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'quality_control' filesep 'group_motion'];
EVs                  = [opt.path_out 'fmri_preprocess_' opt.type_task '_hcp'  filesep 'EVs'];

mkdir(fmri_preprocess);
mkdir(anat);
mkdir(fmri);
mkdir(quality_control);
mkdir(group_coregistration);
mkdir(group_motion);
mkdir(EVs);

%% Extract necessary files and format them in a NIAK like fmri preprocessed ouput folders and files
% Read subjects list and Prune subject that dont have the necessecary folder and flag them in a message
list_subject_raw = dir(path_data);
nb_subject = 0;
for num_ss = 1:length(list_subject_raw)
    if ~ismember(list_subject_raw(num_ss).name,{'.','..'}) && exist([ path_data list_subject_raw(num_ss).name filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/' ],'dir')
       nb_subject = nb_subject + 1;
       sprintf('Adding subject %s', list_subject_raw(num_ss).name)
       list_subject{nb_subject} = list_subject_raw(num_ss).name;     
    else 
       sprintf('subject %s is discarded', list_subject_raw(num_ss).name)
    end  
end   
    
% loop over subject and extract files
for nn = 1:length(list_subject)
    subject_raw = strtrim(list_subject{nn}); % original subject name
    subject = ['HCP' subject_raw] ; % formated subject ID wtih a 'HCP' prefix
    fprintf('Extracting subject %s \n',subject)
    mkdir([anat filesep subject]);
    mkdir([EVs filesep subject]);
    mkdir([EVs filesep subject filesep 'lr']);
    mkdir([EVs filesep subject filesep 'rl']);
    mkdir([quality_control filesep subject]);
    
    % copy the subject anat file (ex: 100307/MNINonLinear/T1w.nii.gz)
    system([cp_opt ' '  path_data subject_raw filesep 'MNINonLinear/T1w.nii.gz ' anat filesep subject filesep 'anat_' subject '_nuc_stereonl.nii.gz']);
    files_ind.(subject).anat = sprintf([anat filesep subject filesep 'anat_' subject '_nuc_stereonl.' ext]);
    
    % copy the subject anat mask file (ex :100307/MNINonLinear/brainmask_fs.nii.gz)
    system([cp_opt ' '  path_data subject_raw filesep 'MNINonLinear/brainmask_fs.nii.gz ' anat filesep subject filesep 'anat_' subject '_mask_stereonl.nii.gz']);
    files_ind.(subject).anat_mask = sprintf([anat filesep subject filesep 'anat_' subject '_mask_stereonl.' ext]);
    
    % collect mask files to create an average anat mask
    mask_anat = [ path_data subject_raw filesep 'MNINonLinear/brainmask_fs.nii.gz'];
    [hdr_ma,mask_a] = niak_read_vol(mask_anat);
    if nn == 1
        mask_anat_avg = mask_a;
    else
        mask_anat_avg = mask_a + mask_anat_avg;
    end 
    
    % copy the subject functional file (ex :100307/MNINonLinear/Results/tfMRI_MOTOR_RL/tfMRI_MOTOR_RL.nii.gz) for each run
    system([cp_opt ' '  path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_RL/tfMRI_' opt.type_task '_RL.nii.gz ' fmri filesep 'fmri_' subject '_session1_' lower(opt.type_task)(1:2) 'RL.nii.gz']);
    files_ind.(subject).fmri.session1.run1 = sprintf([fmri filesep 'fmri_' subject '_session1_' lower(opt.type_task)(1:2) 'RL.' ext]);
    system([cp_opt ' '  path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/tfMRI_' opt.type_task '_LR.nii.gz ' fmri filesep 'fmri_' subject '_session1_' lower(opt.type_task)(1:2) 'LR.nii.gz']);
    files_ind.(subject).fmri.session1.run2 = sprintf([fmri filesep 'fmri_' subject '_session1_' lower(opt.type_task)(1:2) 'LR.' ext]);
    
    % copy the subject functional mask file (ex: 100307/100307_tfMRI_MOTOR_preproc/MNINonLinear/Results/tfMRI_MOTOR_LR/brainmask_fs.2.nii.gz)
    system([cp_opt ' '  path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/brainmask_fs.2.nii.gz ' anat filesep subject filesep 'func_' subject '_mask_stereonl.nii.gz']);
    files_ind.(subject).func.mask = sprintf([anat filesep subject filesep 'func_' subject '_mask_stereonl.' ext]);
    
    % collect mask files to create an average func mask
    mask_func = [ path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_' opt.type_task '_LR/brainmask_fs.2.nii.gz'];
    [hdr_mf,mask_f] = niak_read_vol(mask_func);
    if nn == 1
        mask_func_avg = mask_f;
     else
        mask_func_avg = mask_f + mask_func_avg;
    end
    
    % create a qc_motion_group.csv  file that contain 3 colomn: "", "max_rotation" ,"max_translation" for each subject
    % create a fake qc_scrubing_group.csv that contain 5 colomn: "","frames_scrubbed" ,"frames_OK" ,"FD" ,"FD_scrubbed" for each subject and fill it with 0
    % put these file in /quality_control/group_motion
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
       scrub_csv(nn+1,:)  = { [subject '_session1_' lower(opt.type_task)(1:2) 'RL'], ones, ones*100, ones, ones };
       scrub_csv(nn+2,:)  = { [subject '_session1_' lower(opt.type_task)(1:2) 'LR'], ones, ones*100, ones, ones };
       xcorrf_csv(nn+1,:) = { subject, ones, ones };
       xcorra_csv(nn+1,:) = { subject, ones, ones };
       inc = 0;
    else
       inc = inc+1;
       motion_csv(nn+1,:)    = { subject, ones, ones };
       scrub_csv(nn+inc+1,:) = { [subject '_session1_' lower(opt.type_task)(1:2) 'RL'], ones, ones*100, ones, ones };
       scrub_csv(nn+inc+2,:) = { [subject '_session1_' lower(opt.type_task)(1:2) 'LR'], ones, ones*100, ones, ones };
       xcorrf_csv(nn+1,:)    = { subject, ones, ones };
       xcorra_csv(nn+1,:)    = { subject, ones, ones };
    end
    
    % copy the subject onset file (ex: 100307/MNINonLinear/Results/tfMRI_EMOTION_LR/EVs/ (fear.txt, neut.txt, Stats.txt, Sync.txt)
    system(['cp '  path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_MOTOR_LR/EVs/* ' EVs filesep subject filesep 'lr' filesep '.']);
    system(['cp '  path_data subject_raw filesep 'MNINonLinear/Results/tfMRI_MOTOR_RL/EVs/* ' EVs filesep subject filesep 'rl' filesep '.']);
end

% create an average anat and func mask
fprintf ('Creating an average anat and func mask \n')
mask_anat_avg = mask_anat_avg/length(list_subject);
mask_func_avg = mask_func_avg/length(list_subject);
mask_group_anat = mask_anat_avg > 0.5;
mask_group_func = mask_func_avg > 0.5;

% save the functional and the anat group mask
hdr_ma.file_name = [ group_coregistration filesep 'anat_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr_ma,mask_group_anat);
hdr_mf.file_name = [ group_coregistration filesep 'func_mask_group_stereonl.nii.gz' ];
niak_write_vol(hdr_mf,mask_group_func);
files_group.anat_mask = sprintf([ group_coregistration filesep 'anat_mask_group_stereonl.' ext ]);
files_group.func_mask = sprintf([ group_coregistration filesep 'func_mask_group_stereonl.' ext ]);

% save the csv motion,xcorr func  and scrubbing files
niak_write_csv_cell ([ group_motion filesep 'qc_motion_group.csv' ], motion_csv );
niak_write_csv_cell ([ group_motion filesep 'qc_scrubbing_group.csv' ], scrub_csv );
niak_write_csv_cell ([ group_coregistration filesep 'func_tab_qc_coregister_stereonl.csv' ], xcorrf_csv );
niak_write_csv_cell ([ group_coregistration filesep 'anat_tab_qc_coregister_stereonl.csv' ], xcorrf_csv );

% convert data to mninc 
if strcmp(opt.file_ext,'minc')
   opt_conv.flag_zip = 1;
   niak_brick_nii2mnc(fmri_preprocess, fmri_preprocess, opt_conv);
end

% get the the 3mm  AAL template from github and resampl it to 2mm 
[msg,err]=system(['wget -O ' anat filesep 'template_aal.mnc.gz https://github.com/SIMEXP/niak/raw/master/template/roi_aal_3mm.mnc.gz']);
files_group.ereas      = sprintf([anat filesep 'template_aal.mnc.gz']);
files_in_resamp.source = files_group.ereas; 
files_in_resamp.target = files_group.func_mask;
files_out_resamp       = [anat filesep 'template_aal.mnc.gz'];
opt_resamp.interpolation      = 'nearest_neighbour';
niak_brick_resample_vol (files_in_resamp,files_out_resamp,opt_resamp);


% create the mean functional image of the first run for each subject
if opt.flag_verbose
    fprintf('Averaging volumes. Percentage done :');
    curr_perc = -1;
end
for num_f = 1:length(list_subject)
    subject_raw = strtrim(list_subject{num_f}); % original subject name
    subject = ['HCP' subject_raw] ; % formated subject ID wtih a 'HCP' prefix
    if opt.flag_verbose
        new_perc = 5*floor(20*num_f/length(list_subject));
        if curr_perc~=new_perc
            fprintf(' %1.0f',new_perc);
            curr_perc = new_perc;
        end
    end
    clear vol_f hdr_f mean_vol_ind std_vol_ind
    [hdr_f,vol_f] = niak_read_vol(files_ind.(subject).fmri.session1.run1);
    mean_vol_ind = mean(vol_f,4);
    hdr_f.file_name = sprintf([anat filesep subject filesep 'func_' subject '_mean_stereonl.' ext]);
    niak_write_vol(hdr_f,mean_vol_ind);
    files_mean.(subject).fmri.session1.run1 = hdr_f.file_name;
    std_vol_ind  = std(vol_f,[],4);
    hdr_f.file_name = sprintf([anat filesep subject filesep 'func_' subject '_std_stereonl.' ext]);
    niak_write_vol(hdr_f,std_vol_ind);
    files_std.(subject).fmri.session1.run1 = hdr_f.file_name;
    
    if num_f == 1
       mean_vol_grp = mean(vol_f,4);
       std_vol_grp  = std(vol_f,[],4);
    else    
       mean_vol_grp = mean(vol_f,4) + mean_vol_grp;
       std_vol_grp  = std(vol_f,[],4) + std_vol_grp;
    end
end

mean_vol_grp = mean_vol_grp/length(list_subject);
std_vol_grp  = sqrt((std_vol_grp-length(list_subject)*(mean_vol_grp.^2))/(length(list_subject)-1));

% create xcor, mean_average and mean_std
[cell_fmri_mean,labels] = niak_fmri2cell(files_mean);
files_in.vol             = cell_fmri_mean;
files_in.mask            = files_group.func_mask;
files_out.mean_vol       = [ group_coregistration filesep 'func_mean_average_stereonl.mnc.gz' ];
files_out.std_vol        = [ group_coregistration filesep 'func_mean_std_stereonl.mnc.gz' ];
files_out.tab_coregister = [ group_coregistration filesep 'func_tab_qc_coregister_stereonl.csv' ];
opt_g.labels_subject     = {labels.subject}';
opt_g.folder_out         = group_coregistration;
[files_in,files_out,opt_g] = niak_brick_qc_coregister(files_in,files_out,opt_g);

% Delete all nii.gz files if opt.file_ext ='minc'
if strcmp(opt.file_ext,'minc')
   system(['find ' fmri_preprocess filesep '. -name "*.nii.gz" -delete'])
end