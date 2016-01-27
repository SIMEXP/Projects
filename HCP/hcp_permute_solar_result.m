clear all
%set path
path_root = '/home/yassinebha/Google_Drive/HCP/Solar_heritability/twins_yassine_test/';

%load pdigree and pheno
pedig = niak_read_csv_cell ([path_root 'pedigree_clean.csv']);
pheno = niak_read_csv_cell([path_root 'phenotypes.csv' ]);

%Generate ID permutaion table (1000 permatation)
IDs = pheno(2:end,1);
perm_IDs = {};
for pp = 1:1000
      rand('state',pp);
      order = randperm(length(IDs));
      perm_IDs_tmp = IDs(order',:);
      perm_IDs = [perm_IDs perm_IDs_tmp];
end 

    %loop over permuted ID
          %select random non significant pheno from (sub2_net3)
          %build pheno_tmp(i)
          %build pedig_tmp(i)
          % in solar:
                          %read pedig_tmp(i)
                          %read pheno_tmp(i)
                          %run solar for output_tmp(i)
          %grab output_tmp(i)
          %cocncat result in a varable   
    %end loop

%save resuts in csv file 
                      

    