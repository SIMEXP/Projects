clear all
%set path
path_root = '/home/yassinebha/Google_Drive/HCP/Solar_heritability/twins_permute_exp/';
cd(path_root);

%generate permuted pheno file
pheno = niak_read_csv_cell([path_root '/../phenotypes.csv' ]);
pheno_raw = pheno(2:end,32);
pheno_perm = {};
header_stack = {};
for hh = 1:2200
      rand('state',hh);
      order = randperm(length(pheno_raw));
      pheno_perm_tmp = pheno_raw (order',:);
      pheno_perm = [ pheno_perm pheno_perm_tmp];
      header_name = ['trait_' num2str(hh)];
      header_stack = [header_stack  header_name];
end

%write permuted pheno
pheno_final = [header_stack ; pheno_perm];
pheno_final = [ pheno(:,1:6)  pheno_final ];
niak_write_csv_cell([path_root 'phenotypes_perm.csv'],pheno_final);
niak_write_csv_cell([path_root 'trait_file_perm'],header_stack');

%run solar
system(sprintf('solar <<INTERNAL_SOLAR_SCRIPT \nload pedi %spedigree_clean.csv \nINTERNAL_SOLAR_SCRIPT',path_root))
system(sprintf('solar <<INTERNAL_SOLAR_SCRIPT \nload pheno %sphenotypes_perm.csv \nINTERNAL_SOLAR_SCRIPT',path_root));
system(['bash fcd_solar_h2r.sh trait_file_perm perm_test']);
system(['for i in perm_test/Set-*; do bash $i/run_all.sh ; done']);
