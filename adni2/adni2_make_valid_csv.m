function [files_in]=adni2_make_valid_csv(input_folder,demographic)

addpath(genpath('/home/bellec_group/niak-boss-0.12.2/'));

input_folder = '/home/danserea/database/adni2/20131213_ADNI_RAW/';
demographic = '/home/danserea/svn/projects/adni2/main_scandate_demographic.csv';


[tab,labx,laby] = niak_read_csv(demographic);

tab = [tab, zeros(size(labx))];
laby = [laby;{'exist'}];
cleanlabx = labx;
% check the files
tab_files = {};
files_list = dir([input_folder '/*2_1.mnc.gz']);
for idx = 1:size(files_list,1)
   f_name = files_list(idx).name;
   subjname = f_name(1:4);
   subjid = str2num(subjname);
   subjmask = find(tab(:,1) == subjid);
  
   f_date = f_name(6:13);
   f_datenum =  datenum(f_date,'yyyymmdd');
   for idxmask = 1:size(subjmask,1)
       t_date = datenum(labx{subjmask(idxmask)},'dd-mm-yyyy');
         
         if t_date >= (f_datenum-15) && t_date <= (f_datenum+15)
           cleanlabx{subjmask(idxmask)} = f_date;
           tab(subjmask(idxmask),end) = 1;
         end
     
   end
end

opt.labels_y = laby;
opt.labels_x = cleanlabx;
niak_write_csv([input_folder 'adni2_demographic_XXXXX.csv'],tab,opt);
