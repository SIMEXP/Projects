

input_folder = '/mnt/scratch/bellec/bellec_group/adni2/20131213_ADNI_RAW/';
[tab,labx,laby] = niak_read_csv([input_folder 'adni2_demographic_XXXXX.csv']);

%source = '/mnt/scratch/bellec/bellec_group/adni2/fmri_preprocess/fmri/';
%cd source
files=dir('*.mnc.gz');

for i=1:size(files,1)
fname = files(i).name;
sid = fname(13:16);
sdate = fname(30:37);
status = sum(ismember(labx,sdate).*ismember(tab(:,1),str2num(sid)));

if status ==0
  delete(fname);
  delete([fname(1:end-7) '_extra.mat'])
else 
  ftmp=dir(['*' sid '_session6*.mnc.gz']);
  if size(ftmp,1)>1
    printf([sid '\n'])
  end
end

end



