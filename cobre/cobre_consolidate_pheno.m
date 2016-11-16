clear
path_data = '/home/pbellec/tmp/cobre_minimal';
file_pheno = [path_data filesep 'COBRE_phenotypic_data.csv'];
file_qc = [path_data filesep 'qc_scrubbing_group.csv'];
file_conso = [path_data filesep 'COBRE_phenotypic_data_conso.csv'];

pheno = niak_read_csv_cell(file_pheno);
list_subject = pheno(2:end,1);
list_pheno = pheno(1,2:end);
[data,list_id,list_qc] = niak_read_csv(file_qc);

mask_exist = true(length(list_subject),1);
pheno{1,7} = 'Frames OK';
pheno{1,8} = 'FD';
pheno{1,9} = 'FD scrubbed';
for ss = 1:length(list_subject)
    ind = find(niak_find_str_cell(list_id,list_subject{ss}));
    if isempty(ind)
        warning('Could not find subject %s in the QC',list_subject{ss})
        mask_exist(ss) = false;
    end
    pheno{ss+1,7} = num2str(data(ind,2));
    pheno{ss+1,8} = num2str(data(ind,3));
    pheno{ss+1,9} = num2str(data(ind,4));
end
pheno = pheno([true ; mask_exist],:);
niak_write_csv_cell(file_conso,pheno);