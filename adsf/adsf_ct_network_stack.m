function [files_in,files_out,opt] = adsf_ct_network_stack(files_in,files_out,opt)
%% making subject x vertex array (stack) based on networks

% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = ADSF_CT_NETWORK_STACK(FILES_IN,FILES_OUT,OPT)
% _________________________________________________________________________
% 
% INPUTS:
% 
% FILES_IN 
%   (structure) with the following fields:
%
%   DATA
%       (string) path to .mat file containing the variables
%           CT (2D array) a subject x vertex array where values represent
%               cortical thickness across the whole brain
%           SUBJECTS (cell array) contains list of subject IDs
%
%   PARTITION
%       (string) path to .mat file containing the variable 
%            PART (vector) PART(I) = J if the object I is in the class J.
%               See also: niak_threshold_hierarchy
%
% FILES_OUT
%   (structure) with the field:
%   
%   STACK
%       (cell array, default 'ct_network_%d_stack.mat') path to the mat 
%       files storing the network stacks
%
% OPT 
%   (structure) with the following fields:
%
%   FOLDER_OUT
%       (string, default '') if not empty, this specifies the path where
%       outputs are generated
%
%   NB_NETWORK
%       (integer) number of networks (or resolution/scale)
%
%   FLAG_VERBOSE
%       (boolean, default true) turn on/off the verbose.
%
%   FLAG_TEST
%       (boolean, default false) if the flag is true, the brick does not do 
%       anything but updating the values of FILES_IN, FILES_OUT and OPT.
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%% Initialization and syntax checks

% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = ADSF_CT_NETWORK_STACK(FILES_IN,FILES_OUT,OPT).\n Type ''help adsf_ct_network_stack'' for more info.')
end

% Input
files_in = psom_struct_defaults(files_in,...
           { 'data' , 'partition' },...
           { NaN    , NaN         });

% Options
opt = psom_struct_defaults(opt,...
      { 'folder_out' , 'nb_network' , 'flag_verbose' , 'flag_test' },...
      { ''           , NaN          , true           , false       });

% Output
if ~isempty(opt.folder_out)
    path_out = niak_full_path(opt.folder_out);
    files_out = psom_struct_defaults(files_out,...
                { 'stack'                                                          , 'mask' },...
                { make_paths(path_out, 'ct_network_%d_stack.mat', 1:opt.nb_network),  make_paths(path_out, 'mask_network%d.mat', 1:opt.nb_network)});
else
    files_out = psom_struct_defaults(files_out,...
                { 'stack'          , 'mask'            },...
                { 'gb_niak_omitted', 'gb_niak_omitted' });
end
  
% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% brick starts here

% load the vertex x subject data
data = load(files_in.data);  
ct = data.ct;

n_sub = size(ct,1); % get number of subjects
n_vox = size(ct,2); % number of vertices

% load the basc parcellations
part = load(files_in.partition); 
part = part.part'; 

%% create masks for each network

% find the correct parcellation within part
for pp = 1:size(part,1)
    ind = find(max(part(pp,:)) == opt.nb_network);
    if ind == 1
        n_net = pp;
    end
end

% provenance
provenance.part = part(n_net,:);
provenance.resolution = 9;

for ss = 1:opt.nb_network % iterate over number of networks
    mask = repmat((part(n_net,:) == ss),size(ct,1),1);
    m_name = strcat('net',num2str(ss));
    tmp_mask.(m_name) = mask;
    provenance.network = ss;
    if ~strcmp(files_out.mask, 'gb_niak_omitted')
        save(files_out.mask{ss}, 'mask', 'provenance')
    end
end

%% build the stacks

% make an empty 2d array
ct_net = zeros(n_sub,n_vox); 
mname = fieldnames(tmp_mask);

% save subject list in provenance
provenance.subjects = data.subjects;

% fill array with cortical thickness values per netwok per subject
for cc = 1:opt.nb_network
    stack(:,:) = ct.*tmp_mask.(mname{cc});
    provenance.network = cc;
    if ~strcmp(files_out.stack, 'gb_niak_omitted')
        save(files_out.stack{cc}, 'stack', 'provenance')
    end
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


