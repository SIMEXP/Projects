function [files_in]=adni2_grab_rawmnc(input_folder,demographic)

input_folder = '/home/danserea/database/adni2/rawdata/';
demographic = '/home/danserea/svn/projects/adni2/main_scandate_demographic.csv';


[tab,labx,laby] = niak_read_csv(demographic);


% check the files
tab_files = {};
subjects = dir([input_folder '/subject*']);
for idx = 1:size(subjects,1)
   subjname = subjects(idx).name;
   subjid = str2num(subjname(8:end));
   files_list = dir([input_folder subjname filesep 'fmri' filesep '*.mnc.gz']);
   for files_idx = 1:size(files_list,1)
       fname = files_list(files_idx).name;
       tab_files = [tab_files; [{fname} subjid 2 0]];
   end

   files_list = dir([input_folder subjname filesep 'anat' filesep '*.mnc.gz']);
   for files_idx = 1:size(files_list,1)
       fname = files_list(files_idx).name;
       tab_files = [tab_files; [{fname} subjid 1 0]];
   end

end


% check csv
files_in = struct();
for idx = 1:size(tab,1)
   subjname = int2str(tab(idx,1));
   scandate = [labx{idx}(7:10) labx{idx}(4:5) labx{idx}(1:2)];
   path_fmri = [input_folder 'subject' subjname filesep 'fmri' filesep subjname '_' scandate '_2_1.mnc.gz'];
   tmp_fmri = dir(path_fmri);
   if size(tmp_fmri,1) ~= 0
      if isfield(files_in,['subject' subjname])
         nsession = size(fieldnames(files_in.(['subject' subjname]).fmri),1);
         files_in.(['subject' subjname]).fmri.(['session' int2str(nsession+1)]).(['r' scandate]) = path_fmri;

            detect = ismember(tab_files(:,1),{[subjname '_' scandate '_2_1.mnc.gz']});
            if sum(detect)
              tab_files(find(detect),4) = 1;
            end
      else   
         files_in.(['subject' subjname]).fmri.session1.(['r' scandate]) = path_fmri;
         % check anat
         path_anat = [input_folder 'subject' subjname filesep 'anat' filesep subjname '_' scandate '_1_1.mnc.gz'];
         tmp_anat = dir(path_anat);
         if size(tmp_anat,1) ~= 0
            files_in.(['subject' subjname]).fmri.session1.(['r' scandate]) = path_fmri;
            files_in.(['subject' subjname]).anat = path_anat;
            detect = ismember(tab_files(:,1),{[subjname '_' scandate '_1_1.mnc.gz']});
            if sum(detect)
              tab_files(find(detect),4) = 1;
            end
            detect = ismember(tab_files(:,1),{[subjname '_' scandate '_2_1.mnc.gz']});
            if sum(detect)
              tab_files(find(detect),4) = 1;
            end

         else
            sprintf(['WARNING: Not existant ANAT file for ' subjname ' ScanDate: ' scandate 'at ' path_anat])
         end
      end
   else
      sprintf(['WARNING: Not existant fMRI file for ' subjname ' ScanDate: ' scandate 'at ' path_fmri])
   end
end

opt.labels_y = {'subjid','anat1_fmri2','match'};
opt.labels_x = tab_files(:,1);
niak_write_csv([input_folder 'adni2_files_list.csv'],cell2mat(tab_files(:,2:4)),opt);
