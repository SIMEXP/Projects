clear

path_data = '/media/database3/phenoclust/data/';
file_pheno = '/media/database3/phenoclust/for_pierre/pheno/pheno_unique.csv';

% Read phenotypic info
tab = niak_read_csv_cell(file_pheno);
subject_id = cell2mat(cellfun (@str2num, tab(2:end,3),"UniformOutput", false));
site_id = tab(2:end,2);
for num_subject = 1:length(subject_id)
    file_rmap = [path_data 'rmap_cores' filesep site_id{num_subject} '_00' num2str(subject_id(num_subject))   
end

