function [files_in]=adni2_grab_rawmnc(input_folder,demographic)

%input_folder = '/home/danserea/database/adni2/20131213_ADNI_RAW/';
%demographic = '/home/danserea/database/adni2/20131213_ADNI_RAW/adni2_demographic_XXXXX.csv';


[tab,labx,laby] = niak_read_csv(demographic);
valididx = find(tab(:,end)==1);
tab = tab(valididx,:);
labx = labx(valididx);
% check csv
files_in = struct();
for idx = 1:size(tab,1)
   subjname = int2str(tab(idx,1));
   if size(subjname,2) < 4 subjname = ['0' subjname];end
   scandate = labx{idx};
   path_fmri = [input_folder filesep subjname '_' scandate '_2_1.mnc.gz'];
   tmp_fmri = dir(path_fmri);
   if size(tmp_fmri,1) ~= 0
      if isfield(files_in,['subject' subjname])
         nsession = size(fieldnames(files_in.(['subject' subjname]).fmri),1);
         sessname = ['session' int2str(nsession+1)];
         files_in.(['subject' subjname]).fmri.(sessname).(['r1d' scandate]) = path_fmri;
         
      else   
         % check anat
         path_anat = [input_folder filesep subjname '_' scandate '_1_1.mnc.gz'];
         tmp_anat = dir(path_anat);
         if size(tmp_anat,1) ~= 0
            files_in.(['subject' subjname]).fmri.session1.(['r1d' scandate]) = path_fmri;
            files_in.(['subject' subjname]).anat = path_anat;
            
         else
            sprintf(['WARNING: Not existant ANAT file for ' subjname ' ScanDate: ' scandate 'at ' path_anat])
         end
      end
   else
      sprintf(['WARNING: Not existant fMRI file for ' subjname ' ScanDate: ' scandate 'at ' path_fmri])
   end
end
