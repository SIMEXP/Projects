function [files_in,files_out,opt] = adsf_brick_cog_stack(files_in,files_out,opt)
% making subject x vertex array (stack) based on networks
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = ADSF_COG_NETWORK_STACK(FILES_IN,FILES_OUT,OPT)
% _________________________________________________________________________
% 
% INPUTS:
% 
% FILES_IN 
%   (structure) with the following fields:
%
%   DATA
%       (string) path to .mat file containing the variables
%           <VARIABLE> (2D array) a subject x value array 
%           LIST_SUBJECTS (cell array) contains list of subject IDs
%
%   MODEL
%       (optional, string) path to a .csv containining values for each
%       subject for confound variables
%
%   VARIABLES
%       (Cell of string, Default {}) A list of variables name for stacking
%
% FILES_OUT
%   (structure) with the field:
%   
%   STACK
%       (cell array, default 'cog_var%d_stack.mat') path to the mat 
%       files storing the network stacks
%
% OPT 
%   (structure) with the following fields:
%
%   FOLDER_OUT
%       (string, default '') if not empty, this specifies the path where
%       outputs are generated
%
%   REGRESS_CONF 
%       (Cell of string, Default {}) A list of variables name to be regressed out.
%
%   FLAG_CONF
%       (boolean, default true) turn on/off for confound regression
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
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = ADSF_BRICK_COG_STACK(FILES_IN,FILES_OUT,OPT).\n Type ''help adsf_ct_network_stack'' for more info.')
end

% Input
files_in = psom_struct_defaults(files_in,...
           { 'data' , 'model'           , 'variables'},...
           { NaN    , 'gb_niak_omitted' , {}         });

% Options
opt = psom_struct_defaults(opt,...
      { 'folder_out' , 'regress_conf', 'flag_conf', 'flag_verbose' , 'flag_test' },...
      { ''           , {}            , true       , true           , false       });

% Output
if ~isempty(opt.folder_out)
    path_out = niak_full_path(opt.folder_out);
    files_out = psom_struct_defaults(files_out,...
                { 'stack'                                                         },...
                { make_paths(path_out, 'cog_var%d_stack.mat', 1:length(files_in.variables))});
else
    files_out = psom_struct_defaults(files_out,...
                { 'stack'          , 'mask'            },...
                { 'gb_niak_omitted', 'gb_niak_omitted' });
end
  
% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Additional checks

% Get the model and check if there are any NaNs in the factors to be
% regressed
if ~strcmp(files_in.model, 'gb_niak_omitted')
    [conf_model, ~, cat_names, ~] = niak_read_csv(files_in.model);
    n_conf = length(opt.regress_conf);
    conf_ids = zeros(n_conf, 1);
    % Go through the confound cell array and find the indices
    for cid = 1:n_conf
        conf_name = opt.regress_conf{cid};
        cidx = find(strcmp(cat_names, conf_name));
        % Make sure we found the covariate
        if ~isempty(cidx)
            conf_ids(cid) = cidx;
        else
            error('Could not find column for %s in %s', conf_name, files_in.model);
        end
        % Make sure there are no NaNs in the model
        if any(isnan(conf_model(:, cidx)))
            % Get the indices of the subjects
            missing = find(isnan(conf_model(:, cidx)));
            % Matlab error messages only allow for the double to iterate. Not
            % sure how we could tell them both the subject ID and the confound
            % name
            error('Subject #%d has missing data for one or more confounds. Please fix.\n', missing);
        end
    end
end

%% brick starts here

n_voi = length(files_in.variables);

% load the subject x value data
data = load(files_in.data); 

% save subject list in provenance
provenance.subjects = data.list_subject;

% iterate over number of variables of interest
for nn = 1:n_voi
    voi_name = files_in.variables{nn};
    % load the stack
    voi = data.(voi_name);
    
    % get dimensions
    n_sub = length(provenance.subjects);
    n_val = size(voi,2);
    
    %% Regress confounds
    if ~strcmp(files_in.model, 'gb_niak_omitted')
        % Set up the model structure for the regression
        opt_mod = struct;
        opt_mod.flag_residuals = true;
        m = struct;
        m.x = [ones(length(provenance.subjects),1) conf_model(:, conf_ids)];
        
        conf_stack = zeros(n_sub, n_val);
        
        % Get the correct network
        m.y = voi;
        [res] = niak_glm(m, opt_mod);
        % Store the residuals in the confound stack
        conf_stack = res.e;
    end
    
    %% Build the outputs
    % Decide which of the two stacks to save
    if opt.flag_conf && ~strcmp(files_in.model, 'gb_niak_omitted')
        stack = c_stack;
        provenance.model = struct;
        provenance.model.matrix = m.x;
        provenance.model.confounds = opt.regress_conf;
    else
        stack = voi;
    end
    
    provenance.variable = voi_name;
    
    % Save the stack matrix
    save(files_out.stack, 'stack', 'provenance');

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


