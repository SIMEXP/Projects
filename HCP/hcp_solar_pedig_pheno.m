

subt_weight = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/concat_weight_scores_scale7_niak_preproc_task-specific_prior_LR.csv');
scrub = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/qc_scrubbing_group.csv');
pheno_unrestrict = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/unrestricted_yassinebha_1_13_2016_13_53_17.csv');
pheno_restrict = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/RESTRICTED_yassinebha_1_6_2015_14_22_6.csv');

% add sex to pheno table
subt_weight(:,1)=[] % remove index colomn
pheno_sex = [pheno_unrestrict(:,1) pheno_unrestrict(:,4)];% select only ID and Gender column 
pheno_sex = strrep(pheno_sex,'M','1'); % Change M for 1
pheno_sex = strrep(pheno_sex,'F','2'); % Change F for 2
concat_weight_sex = combine_cell_tab(subt_weight,pheno_sex);
