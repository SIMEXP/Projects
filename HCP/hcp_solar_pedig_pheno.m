
% A non generic script to prepare pedigree and pheno variable for solar eclipse.
% This script will be translated to python for next analysis, and will be coded as 
% generic script for all HCP tasks and rest
addpath(genpath('~/github_repos/Projects')) 
subt_weight = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/concat_weight_scores_scale7_niak_preproc_task-specific_prior_LR.csv');
scrub = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/qc_scrubbing_group.csv');
pheno_unrestrict = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/unrestricted_yassinebha_1_13_2016_13_53_17.csv');
pheno_restrict = niak_read_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/RESTRICTED_yassinebha_1_6_2015_14_22_6.csv');

% Add sex to pheno table
subt_weight(:,1)=[]; % Remove index colomn
pheno_sex = [pheno_unrestrict(:,1) pheno_unrestrict(:,4)];% Select only ID and Gender column 
pheno_sex = strrep(pheno_sex,'M','1'); % Change M for 1
pheno_sex = strrep(pheno_sex,'F','2'); % Change F for 2
concat_weight_sex = combine_cell_tab(subt_weight,pheno_sex);

%Add FD and FD scrubbed to concat_weight_sex
scrub_FD = [scrub(:,1) scrub(:,4) scrub(:,5)]; % Select IDs, FD and FD scrubbed
scrub_FD_header = scrub_FD(1,:); %grab the header
index = strfind(scrub_FD(:,1),'motLR'); % find index matching the task name
index = find(~cellfun(@isempty,index)); % select only matching index
scrub_FD_clean = scrub_FD(index,:); % keep only matching task name
for ii = 1:length(scrub_FD_clean)
    scrub_FD_clean(ii,1)=scrub_FD_clean{ii,1}(4:end-12); %keep only subject name in the ID
end
scrub_FD_clean = [scrub_FD_header ; scrub_FD_clean]; %put back the header
concat_weight_sex_FD = combine_cell_tab(concat_weight_sex,scrub_FD_clean);

%Build and save pheno Table
phenotype = [concat_weight_sex_FD(:,1) concat_weight_sex_FD(:,5) concat_weight_sex_FD(:,43) concat_weight_sex_FD(:,6) concat_weight_sex_FD(:,45:46) concat_weight_sex_FD(:,7:41)]; %select specific pheno
phenotype(1,1)= 'ID'; % Change Subject for ID in the header
%phenotype(cellfun(@(x) any(isnan(x)),phenotype))=[]; %remove NaN
%niak_write_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/test_pheno.csv',concat_weight_sex_FD);
niak_write_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/phenotypes.csv',phenotype);

% Build pedigree table
pedigree = [concat_weight_sex_FD(:,1) concat_weight_sex_FD(:,4) concat_weight_sex_FD(:,4) concat_weight_sex_FD(:,43) concat_weight_sex_FD(:,2) concat_weight_sex_FD(:,4)];
pedigree_header = {'ID','fa','mo','sex','mztwin','hhID'};
pedigree_tab = pedigree(2:end,:);
for pp = 1:length(pedigree_tab)
    pedigree_tab(pp,2)=['fa_' pedigree_tab{pp,2}];%add prefix "fa" for father ID
    pedigree_tab(pp,3)=['mo_' pedigree_tab{pp,3}];%add prefix "mo" for mother ID
    if strcmp(pedigree_tab{pp,5}, 'MZ') 
       pedigree_tab(pp,5)=['pair_' pedigree_tab{pp,6}];%add prefix "pair" if MZ twins, and empty if not
    else
       pedigree_tab(pp,5)={''};
    end
    pedigree_tab(pp,6)=['hh_' pedigree_tab{pp,6}];%add prefix "hh" household ID
end
pedegree_clean = [pedigree_header ;  pedigree_tab];
niak_write_csv_cell('/home/yassinebha/Google_Drive/HCP/Solar_heritability/pedegree.csv',pedegree_clean);
