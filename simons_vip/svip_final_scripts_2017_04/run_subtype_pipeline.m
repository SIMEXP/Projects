%%% test session1
clear
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak_issue263/'))

base_path = '/gs/project/gsf-624-aa/simons_vip/';
files_in.model = '/gs/project/gsf-624-aa/simons_vip/pheno/phenotype_all_both_sessions_norm.csv';
path_connectome = '/gs/project/gsf-624-aa/simons_vip/connectomes/cambridge012';

files_conn = niak_grab_connectome(path_connectome);
files_in.data = files_conn.rmap;

%TODO: get an actual mask instead of this hack
files_in.mask = '/gs/project/gsf-624-aa/simons_vip/template/template_cambridge_basc_multiscale_asym_scale012.nii.gz' ;

opt.folder_out = [base_path filesep 'subtypes/the_norm'];

opt.subtype.nb_subtype = 3;        % the number of subtypes to extract
opt.subtype.sub_map_type = 'mean'; % the model for the subtype maps (options are 'mean' or 'median')

opt.stack.regress_conf = {'FD_scrubbed_both_sessions_norm';'Site_dummy'}; % or FD_scubbed_m (FD_scrubbed_m) or FDm

%%%% mean con  %%%%%
opt.association.mean_con.contrast.g1 = 0; %del
opt.association.mean_con.contrast.g2 = 1; %con
opt.association.mean_con.contrast.g3 = 0; %dup
opt.association.mean_con.contrast.sex_dummy = 0;
opt.association.mean_con.contrast.age_months_norm = 0;
opt.association.mean_con.contrast.BV_norm = 0;
opt.association.mean_con.flag_intercept = false;
opt.association.mean_con.normalize_x = false;
opt.association.mean_con.normalize_y = false;
opt.association.mean_con.fdr = 0.05;

%%%% mean del  %%%%%
opt.association.mean_del.contrast.g1 = 1; %del
opt.association.mean_del.contrast.g2 = 0; %con
opt.association.mean_del.contrast.g3 = 0; %dup
opt.association.mean_del.contrast.sex_dummy = 0;
opt.association.mean_del.contrast.age_months_norm = 0;
opt.association.mean_del.contrast.BV_norm = 0;
opt.association.mean_del.flag_intercept = false;
opt.association.mean_del.normalize_x = false;
opt.association.mean_del.normalize_y = false;
opt.association.mean_del.fdr = 0.05;

%%%% mean dup  %%%%%
opt.association.mean_dup.contrast.g1 = 0; %del
opt.association.mean_dup.contrast.g2 = 1; %con
opt.association.mean_dup.contrast.g3 = 0; %dup
opt.association.mean_dup.contrast.sex_dummy = 0;
opt.association.mean_dup.contrast.age_months_norm = 0;
opt.association.mean_dup.contrast.BV_norm = 0;
opt.association.mean_dup.flag_intercept = false;
opt.association.mean_dup.normalize_x = false;
opt.association.mean_dup.normalize_y = false;
opt.association.mean_dup.fdr = 0.05;

%%%% del-dup %%%%%
opt.association.del_minus_dup.contrast.g1 = 1; %del
opt.association.del_minus_dup.contrast.sex_dummy = 0;
opt.association.del_minus_dup.contrast.age_months_norm = 0;
opt.association.del_minus_dup.contrast.BV_norm = 0;
opt.association.del_minus_dup.select(1).label = 'g2';
opt.association.del_minus_dup.select(1).values = 0;
opt.association.del_minus_dup.flag_intercept = true;
opt.association.del_minus_dup.normalize_x = false;
opt.association.del_minus_dup.normalize_y = false;

%%%% del-con %%%%%
opt.association.del_minus_con.contrast.g1 = 1; %dup
opt.association.del_minus_con.flag_intercept = true;
opt.association.del_minus_con.normalize_x = false;
opt.association.del_minus_con.normalize_y = false;
opt.association.del_minus_con.contrast.sex_dummy = 0;
opt.association.del_minus_con.contrast.age_months_norm = 0;
opt.association.del_minus_con.contrast.BV_norm = 0;
opt.association.del_minus_con.select(1).label = 'g3';
opt.association.del_minus_con.select(1).values = 0;

%%%% dup-con %%%%%
opt.association.dup_minus_con.contrast.g3 = 1; %dup
opt.association.dup_minus_con.contrast.sex_dummy = 0;
opt.association.dup_minus_con.contrast.age_months_norm = 0;
opt.association.dup_minus_con.contrast.BV_norm = 0;
opt.association.dup_minus_con.select(1).label = 'g1';
opt.association.dup_minus_con.select(1).values = 0;
opt.association.dup_minus_con.flag_intercept = true;
opt.association.dup_minus_con.normalize_x = false;
opt.association.dup_minus_con.normalize_y = false;

%opt.chi2 = 'genetic_status';
opt.flag_test = false;  % Put this flag to true to just generate the pipeline without running it.

pipeline = niak_pipeline_subtype(files_in,opt);
