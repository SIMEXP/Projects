% A non generic script to prepare to merge pheno table with scrubbing.
pheno_unrestrict = niak_read_csv_cell('/media/yassinebha/database21/Google_Drive/HCP/subtypes_scores/unrestricted_yassinebha_1_13_2016_13_53_17.csv');
scrub = niak_read_csv_cell('/media/yassinebha/database21/Google_Drive/HCP/subtypes_scores/qc_scrubbing_group.csv');

%Add FD and FD scrubbed to Pheno table
scrub_FD = [scrub(:,1) scrub(:,4) scrub(:,5)]; % Select IDs, FD and FD scrubbed
scrub_FD_header = scrub_FD(1,:); %grab the header
index = strfind(scrub_FD(:,1),'motLR'); % find index matching the task name
index = find(~cellfun(@isempty,index)); % select only matching index
scrub_FD_clean = scrub_FD(index,:); % keep only matching task name
for ii = 1:length(scrub_FD_clean)
    scrub_FD_clean(ii,1)=scrub_FD_clean{ii,1}(4:end-12); %keep only subject name in the ID
end
scrub_FD_clean = [scrub_FD_header ; scrub_FD_clean]; %put back the header
merge_pheno_FD = combine_cell_tab(pheno_unrestrict,scrub_FD_clean);
niak_write_csv_cell('/media/yassinebha/database21/Google_Drive/HCP/subtypes_scores/unrestricted_yassinebha_1_13_2016_13_53_17_FD.csv',merge_pheno_FD);
