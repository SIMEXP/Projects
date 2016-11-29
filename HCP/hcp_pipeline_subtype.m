% Template to write a script for the NIAK subtyping pipeline
%
% To run a demo of the subtyping, please see
% NIAK_DEMO_SUBTYPE.
%
% Copyright (c) Pierre Bellec, Sebastian Urchs, Angela Tam
%   Montreal Neurological Institute, McGill University, 2008-2016.
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Qubec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, clustering, pipeline

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

%% Clear the workspace 
clear all

%% Set up the files_in structure

path_maps = '/home/yassinebha/scratch/HCP/stability_scores_MOTOR_niak_preproc-fix-scrub_900R_basc_prior_rl-lr/rmap_part/';
file_pheno = '/gs/project/gsf-624-aa/HCP/pheno/hcp_all_pheno.csv'; 
file_scrub = '/gs/project/gsf-624-aa/HCP/fmri_preprocess_all_tasks_niak-fix-scrub_900R/quality_control/group_motion/qc_scrubbing_group.csv';
scrub_raw = niak_read_csv_cell (file_scrub);
pheno_raw  = niak_read_csv_cell (file_pheno);

list_pheno  = {'Age_in_Yrs','Twin_Stat','Zygosity','Mother_ID','Father_ID','Handedness','Gender','Endurance_Unadj','Endurance_AgeAdj','Dexterity_Unadj','Dexterity_AgeAdj','Strength_Unadj','Strength_AgeAdj'};
list_scrub = {'','FD','FD_scrubbed'};

mask_pheno  = ismember(pheno_raw(1,:),list_pheno);
pheno_clean = pheno_raw(:,mask_pheno);
% add the IDs colomn
pheno_clean = [pheno_raw(:,ismember(pheno_raw(1,:),'Subject'))(:,1) pheno_clean];

list_subject = {dir(path_maps).name};
list_subject = list_subject(~ismember(list_subject,{'.','..'}));
mask_id_stack = zeros(length(pheno_clean)-1,1);
for num_s = 1:length(list_subject)
    tmp = strsplit(list_subject{num_s},'_');
    subject = tmp{1};
    session = tmp{2};
    run = tmp{3};
    if strcmp(run, "motLR")
       continue
    end
    files_in.data.(subject) = [path_maps filesep sprintf('%s_%s_%s_rmap_part.mnc.gz',subject,session,run)];
    mask_id = ismember(pheno_clean(2:end,1),subject(4:end));
    if sum(mask_id) == 0
       warning(sprintf('subject %s has no entry in the csv model',subject))
       continue
    elseif  sum(mask_id) == 1
       mask_id_stack = mask_id_stack + mask_id; 
    else
       error('subject %s has more than one entry',subject)
    end
end

% Put header on the mask
mask_id_stack= [1;mask_id_stack];
% extract correspondind subjects only 
pheno_clean_final = pheno_clean(logical(mask_id_stack),:);

%Add the scrubbing to pheno_clean_final
% Select IDs, FD and FD scrubbed
mask_scrub  = ismember(scrub_raw(1,:),list_scrub);
scrub_clean = scrub_raw(:,mask_scrub);
scrub_clean_header = scrub_clean(1,:); %grab the header
index = strfind(scrub_clean(:,1),'motRL'); % find index matching the task name
index = find(~cellfun(@isempty,index)); % select only matching index
scrub_clean_final = scrub_clean(index,:); % keep only matching task name
for ii = 1:length(scrub_clean_final)
    scrub_clean_final(ii,1)=scrub_clean_final{ii,1}(4:end-12); %keep only subject name in the ID
end
scrub_clean_final = [scrub_clean_header ; scrub_clean_final]; %put back the header
merge_pheno_scrub = combine_cell_tab(pheno_clean_final,scrub_clean_final); 
%remove extra subject id colomn
merge_pheno_scrub = merge_pheno_scrub(:,~ismember(merge_pheno_scrub(1,:),''));
%add HCP prefix to the subejects ID
merge_pheno_scrub(2:end,1) = strcat('HCP',merge_pheno_scrub(2:end,1));
%recode gender to M=1 F=0
index = strfind(merge_pheno_scrub(1,:),'Gender');
index = find(~cellfun(@isempty,index));
merge_pheno_scrub(:,index) = strrep (merge_pheno_scrub(:,index),'M','1');
merge_pheno_scrub(:,index) = strrep (merge_pheno_scrub(:,index),'F','0');
%save final model file
path_model_final = '/gs/project/gsf-624-aa/HCP/pheno/motor_RL_pheno_scrub.csv';
niak_write_csv_cell(path_model_final,merge_pheno_scrub);



% Mask
files_in.mask = '/home/yassinebha/scratch/HCP/stability_scores_MOTOR_niak_preproc-fix-scrub_900R_basc_prior_rl-lr/mask.mnc.gz';     % a 3D binary mask

% Model
files_in.model = '/home/yassinebha/scratch/HCP/stability_scores_MOTOR_niak_preproc-fix-scrub_900R_basc_prior_rl-lr/demoniak_model_group.csv';

%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%

%% General
opt.folder_out = '/home/yassinebha/scratch/HCP/subtype_results/';     % where to store the results
opt.scale = 6;                                      % integer for the number of networks specified in files_in.data

%% Stack
opt.stack.flag_conf = true;                    % turn on/off regression of confounds during stacking (true: apply / false: don't apply)
opt.stack.regress_conf = {'Age_in_Yrs','Gender','Handedness','FD'};     % a list of varaible names to be regressed out

%% Subtyping
opt.subtype.nb_subtype = 5;       % the number of subtypes to extract
opt.sub_map_type = 'mean';        % the model for the subtype maps (options are 'mean' or 'median')

%% Association testing via GLM

% GLM options
opt.flag_assoc = true;                                % turn on/off GLM association testing (true: apply / false: don't apply)
opt.association.fdr = 0.05;                           % scalar number for the level of acceptable false-discovery rate (FDR) for the t-maps
opt.association.type_fdr = 'BH';                      % method for how the FDR is controlled
opt.association.normalize_x = true;                   % turn on/off normalization of covariates in model (true: apply / false: don't apply)
opt.association.normalize_y = false;                  % turn on/off normalization of all data (true: apply / false: don't apply)
opt.association.normalize_type = 'mean';              % type of correction for normalization (options: 'mean', 'mean_var')
opt.association.flag_intercept = true;                % turn on/off adding a constant covariate to the model

% Note the pipeline can only test one main effect or interaction at a time

% To test a main effect of a variable
opt.association.contrast.variable_of_interest = 1;    % scalar number for the weight of the variable in the contrast
opt.association.contrast.confound1 = 0;               % scalar number for the weight of the variable in the contrast
opt.association.contrast.confound2 = 0;               % scalar number for the weight of the variable in the contrast

% To test an interaction
opt.association.interaction(1).label = 'interaction1';              % string label for the interaction
opt.association.interaction(1).factor = {'variable1','variable2'};  % covariates (cell of strings) that are being multiplied together to build the interaction
opt.association.contrast.interaction1 = 1;                          % scalar number for the weight of the interaction
opt.association.contrast.variable1 = 0;                             % scalar number for the weight of the variable in the contrast
opt.association.contrast.variable2 = 0;                             % scalar number for the weight of the variable in the contrast
opt.association.flag_normalize_inter = true;  % turn on/off normalization of factors to zero mean and unit variance prior to the interaction


% Visualization
opt.flag_visu = true;               % turn on/off making plots for GLM testing (true: apply / false: don't apply)
opt.visu.data_type = 'continuous';  % type of data for contrast or interaction in opt.association (options are 'continuous' or 'categorical')

%% Chi2 statistics

opt.flag_chi2 = true;               % turn on/off running Chi-square test (true: apply / false: don't apply)
opt.chi2.group_col_id = 'Group';    % string name of the column in files_in.model on which the contigency table will be based


%%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline  %%
%%%%%%%%%%%%%%%%%%%%%%%

opt.flag_test = false;  % Put this flag to true to just generate the pipeline without running it.
[pipeline,opt] = niak_pipeline_subtype(files_in,opt);

