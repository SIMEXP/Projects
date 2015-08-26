%  This script grab raw DICOM and convert them to minc
%  
%  the files to be grabbed are : 
%  'MPRAGE' dans SCAP1 ou FCAP1
%  'RESTING' dans FCAP
%  'resting' dans FCAP
%  'rs' dans FCAP
%  'RS' dans FCAP
%  'mri' dans FCAP
%  'MRI' dans FCAP

clear all

path_data = '/peuplier/scratch1/simons_vip/raw_dicom/';
path_out ='/peuplier/scratch1/simons_vip/raw_dicom/';

% Grab the raw data
%% list subject id
list_subject = dir(path_data);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..','PhilipsParameters.xlsx','ReadMe_SimonsVIP_Data_Release_20140925.txt','SiemensParameters.xlsx','Thumbs.db'}));

for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    tmp_path_subj = [path_data subject filesep];
    list_subj_directory = {dir([tmp_path_subj '*/*/*']).name}
%  the files to be grabbed are : 
%  'MPRAGE' dans SCAP1 ou FCAP1
%  'RESTING' dans FCAP
%  'resting' dans FCAP
%  'rs' dans FCAP
%  'RS' dans FCAP
%  'mri' dans FCAP
%  'MRI' dans FCAP
end