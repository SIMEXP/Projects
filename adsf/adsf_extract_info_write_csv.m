
%% script to extract variables from an existing csv and compute new variables into a new csv
%%%%%%%% make sure the csv does not contain any NaN %%%%%%%%

clear

path_data = '/Users/AngelaTam/Desktop/adsf/';
file_data = [path_data 'adsf_model_preventad_bl_dr2_20160125_nan.csv'];
[tab,lx,ly] = niak_read_csv(file_data);

% Extract model
model = tab(:,1:22);
labels_model = ly(1:22);

% Extract volume measures
vol = tab(:,23:end);
labels_vol = ly(23:end);

vol(:,2:end) = vol(:,2:end) .* repmat(vol(:,1),[1 size(vol,2)-1]);

mask = max(isnan(vol),[],2);
vol = vol(~mask,:);
vol = niak_normalize_tseries(vol);
nb_vol = 5;
R = niak_build_correlation(vol);
hier = niak_hierarchical_clustering(R);
part_vol = niak_threshold_hierarchy(hier,struct('thresh',nb_vol));

subt1 = 0;
subt2 = 0;
subt3 = 0;
subt4 = 0;
subt5 = 0;

% add the variables for each cluster together

for n = 1:length(part_vol)
    if part_vol(n) ==1
       subt1_tmp = vol(:,n);
       subt1 = subt1 + subt1_tmp;  
    elseif part_vol(n) ==2
        subt2_tmp = vol(:,n);
        subt2 = subt2 + subt2_tmp;    
    elseif part_vol(n) ==3
        subt3_tmp = vol(:,n);
        subt3 = subt3 + subt3_tmp;   
    elseif part_vol(n) ==4
        subt4_tmp = vol(:,n);
        subt4 = subt4 + subt4_tmp;
    elseif part_vol(n) ==5
        subt5_tmp = vol(:,n);
        subt5 = subt5 + subt5_tmp;
    end
end
    
table(:,1) = subt1;
table(:,2) = subt2;
table(:,3) = subt3;
table(:,4) = subt4;
table(:,5) = subt5;

list_subject = lx;
labels_subt = {'subt1_tot','subt2_tot','subt3_tot','subt4_tot','subt5_tot'};

% write csv
file_write = [pwd filesep 'adsf_vol_avg.csv'];
opt_w.labels_x = list_subject;
opt_w.labels_y = labels_subt;
niak_write_csv(file_write,table,opt_w)














