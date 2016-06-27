%% script to check availabilty of images in maven database and arrange them 
%% according to the bids format

clear
path_mnc = '/media/yassinebha/database24/MAVEN_06_2016/raw_mnc/';
list_subject = dir(path_mnc);
list_subject = {list_subject(3:end).name};
list_subject = list_subject(~ismember(list_subject,{'.','..','octave-wokspace','octave-core','qc_report.csv','logs_conversion'}));
for ll = 1:length(list_subject)
    subject_ID = list_subject{ll};
    fprintf('\n  Subject %s\n',subject_ID);
    path_in = [path_mnc subject_ID '/tmp/'];
    list_file = dir(path_in);
    list_file = {list_file(3:end).name};
    list_file = list_file(~ismember(list_file,{'.','..','octave-wokspace','octave-core'}));
    flag_exist = zeros(1,4);
    for ii = 1:length(list_file)
        [status,output] = system(['mincheader ' path_in list_file{ii} ' |grep acquisition:protocol']);
        output  = strtrim(output);
        pos = strfind (output,'"');
        pattern = output(pos(1):pos(2));
        switch pattern
               case '"RSN_1(ep2d_64)"'
               system(['scp -r ' path_in list_file{ii} ' ' path_mnc subject_ID '/func/' subject_ID '_task-rest1_run-01_bold.mnc' ]);
               fprintf('Rest1 file "%s" found for subject %s\n',list_file{ii},subject_ID);
               flag_exist(1,1) = true;
               
               case '"RSN_2(ep2d_64)"'
               system(['scp -r ' path_in list_file{ii}  ' ' path_mnc subject_ID '/func/' subject_ID '_task-rest2inscape_run-02_bold.mnc' ]);
               fprintf('Rest2 file "%s" found for subject %s\n',list_file{ii},subject_ID);
               flag_exist(1,2) = true;
               
               case '"RSN_3(ep2d_64)"'
               system(['scp -r ' path_in list_file{ii}  ' ' path_mnc subject_ID '/func/' subject_ID '_task-rest3_run-03_bold.mnc' ]);
               fprintf('Rest3 file "%s" found for subject %s\n',list_file{ii},subject_ID);
               flag_exist(1,3) = true;
               
               case '"MPRAGE (t1_mprage)"'
               system(['scp -r ' path_in list_file{ii}  ' ' path_mnc subject_ID '/anat/' subject_ID '_T1w.mnc' ]);
               fprintf('MPRAGE file "%s" found for subject %s\n',list_file{ii},subject_ID);
               flag_exist(1,4) = true;
       end
    end
    if sum(flag_exist(1,1:3)) == 0
       fprintf('WARNING:subject %s has some missing run\n', subject_ID);
    end
    if flag_exist(1,4) == 0
       fprintf('FATAL-WARNING:subject %s missing anat file\n', subject_ID);
    end
end
       