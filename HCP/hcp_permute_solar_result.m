%set path

%load pdigree and pheno

%Generate ID permutaion table (1000 permatation)

    %loop over permated ID
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
                      

    