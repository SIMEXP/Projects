function files = niak_extract_preprocess_hcp(path_data,opt)
% Extract files preprocessed by HCP Pipelines, and format then in niak like structure 
%
% SYNTAX:
% FILES = NIAK_EXTRACT_PREPROCESSED_HCP(PATH_DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DATA
%   (string, default [pwd filesep], aka './') full path to the outputs of 
%   HCP Preprocessed data. 
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

%% Default path for the database
if (nargin<1)||isempty(path_data)
    path_data = [pwd filesep];
end

if ~strcmp(path_data(end),filesep)
    path_data = [path_data filesep];
end

%% Default options
list_fields   = { 'type_task' , 'path_out'    };
list_defaults = { 'motor'     , [pwd filesep] };
if nargin > 1
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end




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