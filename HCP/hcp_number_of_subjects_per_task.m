%count how many subjects for each run on hcp preprocessed tasks

path_fmri = '/gs/project/gsf-624-aa/HCP/fmri_preprocess_all_tasks_niak/fmri';
sessions = {'sess1_wmRL','sess1_wmLR','sess1_gambRL',...
'sess1_gambLR','sess1_motRL','sess1_motLR','sess2_langRL',...
'sess2_langLR','sess2_socRL','sess2_socLR','sess2_relRL',...
'sess2_relLR','sess2_emRL','sess2_emLR'};
num_subj = struct();
for ss = 1:length(sessions)
    files_fmri = dir([path_fmri  '/fmri_*_' sessions{ss} '.mnc.gz']);
    num_subj.(sessions{ss}) = length({files_fmri.name});
    niak_progress(ss,length(sessions))
end
num_subj