path_mnc = '/media/yassinebha/database24/MAVEN_06_2016/raw_mnc/';
path_dcm = '/media/yassinebha/database24/MAVEN_06_2016/raw_dcm/';
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};
list_subject = list_subject(~ismember(list_subject,{'.','..','octave-wokspace','octave-core','qc_report.csv','log_conversion'}));
for ll = 1:length(list_subject)
    subject_folder = list_subject{num_s};
    subject_ID = subject_folder(1:(strfind(subject_folder,'_')(1))-1);
    subject_ID_tmp = subject_ID;
    subject_ID(strfind(subject_ID,'-')) = [];
    fprintf('Subject %s\n',subject_ID);
    
    path_in = [path_mnc subject_ID '/tmp/'lower(subject_folder) filesep];
    list_file = dir(path_in);
    list_file = {list_file(3:end).name};
    list_file = list_file(~ismember(list_file,{'.','..','octave-wokspace','octave-core'}));
    for ii = 1:length(list_file)
        [status,output] = system(['mincheader ' path_in list_file{ii} ' |grep acquisition:protocol']);
        output  = strtrim(output);
        pos = strfind (output,'"');
        pattern = output(pos(1):pos(2));
        switch pattern
               case '"RSN_1(ep2d_64)"'
               system(['scp -r ' path_in list_file{ii}  path_mnc subject_ID '/func/' subject_ID '_task-rest1_run-01_bold.mnc' ]);
               fprintf('Rest1 found for subject %s\n',subject_ID);
               
               case ' "RSN_2(ep2d_64)"'
               ['scp -r ' path_in list_file{ii}  path_mnc subject_ID '/func/' subject_ID '_task-rest2inscape_run-02_bold.mnc' ];
               fprintf('Rest1 found for subject %s\n',subject_ID);
               
               case '"RSN_3(ep2d_64)"'
               ['scp -r ' path_in list_file{ii}  path_mnc subject_ID '/anat/' subject_ID '_task-rest3_run-03_bold.mnc' ];
               fprintf('Rest1 found for subject %s\n',subject_ID);
               
               case '"MPRAGE (t1_mprage)"'
               ['scp -r ' path_in list_file{ii}  path_mnc subject_ID '/anat/' subject_ID '_T1w.mnc' ];
               fprintf('Rest1 found for subject %s\n',subject_ID);
       else  
       fprintf('no images found  for subject %s\n',subject_ID);   