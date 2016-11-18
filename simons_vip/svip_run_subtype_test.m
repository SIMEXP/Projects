clear;

base_path = "/gs/project/gsf-624-aa/simons_vip/";
model_path = "/gs/project/gsf-624-aa/simons_vip/pheno/dataset_good_16p.csv";
in_path = [base_path filesep "scores/scores_11_07/rmap_part"];
mask_path = "/gs/project/gsf-624-aa/simons_vip/mask/func_mask_average_stereonl.nii.gz";

% Load model
[tab,labels_x,labels_y,labels_id] = niak_read_csv(model_path);
n_files = length(labels_x);

files_in = struct;
for fid = 1:n_files
        sub_file_name = labels_x{fid};

        temp = strsplit(sub_file_name, "_");
        sub_name = temp{1};
        session = temp{2};
        run = temp{3};

        if strcmp(session, "session2")
                continue
        end
        files_in.data.(sub_name) = [in_path filesep sprintf("%s_session1_rest_rmap_part.nii.gz", sub_name)];
end

% add the model
files_in.model = model_path;
% add the mask
files_in.mask = mask_path;

% Set up some options
opt = struct;
opt.folder_out = [base_path filesep "subtypes3_16p_dup_noage"];
opt.scale = 7;
% Name of confounds to regress
opt.stack.regress_conf = {"sex", "FD_scrubbed"};
% Number of subtypes
opt.subtype.nb_subtype = 3;
% Setup association tests
opt.association.contrast.g1 = 0; %del
opt.association.contrast.g2 = 0; %con
opt.association.contrast.g3 = 1; %dup
opt.association.contrast.age_months = 0;
opt.association.flag_intercept = false;
%pwdopt.association.fdr = 1;


opt.flag_visu = false;
opt.flag_chi2 = false;

% Run the pipeline
fprintf("Lets go now\n");
niak_pipeline_subtype(files_in, opt);
