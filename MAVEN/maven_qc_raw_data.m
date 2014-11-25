function [] = niak_qc_raw_data(opt)
% Quality control of the raw data
%
% SYNTAX:
% [] = NIAK_QC_RAW_DATA( OPT )
%
% _________________________________________________________________________
% INPUTS:
%
% OPT
%   (structure) with the following fields:
%
%   PATH_QC
%      (string, default current folder) the folder where the results of the 
%      fMRI preprocessing pipeline are located
%
%   LIST_SUBJECT
%      (string or cell of strings, default all subjects) the ID of the subject
%
%   FLAG_RESTART
%      (boolean, default false) restart the QC of subjects which have already
%      a complete entry in the QC report. 
%
% _________________________________________________________________________
% OUTPUTS:
%
% None
%           
% _________________________________________________________________________
% SEE ALSO:
% NIAK_PIPELINE_FMRI_PREPROCESS
%
% _________________________________________________________________________
% COMMENTS:
%
% This tool for quality control depends on the "register" visualization tool,
% which is part of the MINC tools. This will work only with images in the 
% MINC format. The following coregistration are presented for each subject:
%    * T1 scan in stereotaxic space vs the anatomical template
%    * T1 scan in stereotaxic space vs average functional scan in stereotaxic space
% Scans are co-registered with a non-linear transformation. 
%
% The function interactively asks for feedback in the command line. The results 
% are stored in a file "qc_report.csv" in PATH_QC. Unless OPT.FLAG_RESTART is 
% specified, subjects for which the QC has been completed will not be
% re-assessed.
%
% _________________________________________________________________________
% Copyright (c) Yassine Benhajali, Pierre Bellec
% Centre de recherche de l'institut de gériatrie de Montréal, 
% Department of Computer Science and Operations Research
% University of Montreal, Québec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI preprocessing, quality control

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Set default options
list_fields   = { 'path_qc' , 'list_subject' , 'flag_restart' };
list_defaults = { pwd       , {}             , false          };
if nargin == 0
    opt = struct();
end
opt = psom_struct_defaults(opt,list_fields,list_defaults);

%% Set default for the path for QC
path_qc = niak_full_path(opt.path_qc);

%% Grab the raw data set

path_raw_fmri = path_qc;
subjects_list = dir([path_raw_fmri]);
subjects_list = {subjects_list(3:end).name};

%%  Subject names
    for subject_n = 1:length(subjects_list)
        subject = subjects_list{ subject_n};
        fprintf('Subject %s\n',subject)
        % subject runs
        subject_run = dir([path_raw_fmri subject filesep 'func/']);
        subject_run = {subject_run(3:end).name};
        
%%      loop over runs
        for num_run = 1:length(subject_run)
            run = subject_run{num_run};
            fprintf('   %s\n',run)
            
%%          Adding the subject to the list of files
            path_fmri = [path_raw_fmri subject filesep 'func/' run filesep];
            fmri_file = dir([path_fmri "RSN*"]);
            files.([subject 'run' num2str(num_run)]).fmri =[path_fmri fmri_file.name];
            
            path_anat = [path_raw_fmri subject filesep 'anat/'];
            anat_file = dir([path_anat "MPRAGEt1mprages009a1001*"]);
            files.([subject 'run' num2str(num_run)]).anat=[path_anat anat_file.name];
        end
    end

%% Set default for the list of subjects
list_subject = opt.list_subject;

if ischar(list_subject)
    list_subject = {list_subject};
end

if isempty(list_subject)
    list_subject = fieldnames(files);
end

%% Look for an existing QC report
file_qc = [path_qc 'qc_report.csv'];
if psom_exist(file_qc)
    qc_report = niak_read_csv_cell(file_qc);
else
    qc_report = cell(length(list_subject)+1,6);
    qc_report(2:end,1) = list_subject;
    qc_report(1) = 'id_subject';
    qc_report(1,2) = 'status';
    qc_report(1,3) = 'anat';
    qc_report(1,4) = 'comment_anat';
    qc_report(1,5) = 'func';
    qc_report(1,6) = 'comment_func';
    qc_report(2:end,2:end) = repmat({''},[length(list_subject),5]);
end


%% Loop over subjects
for num_s = 1:length(list_subject)

    % Initialize the report    
    subject = list_subject{num_s};        
    fprintf('\nQuality control of Subject %s\n',subject)    
    if ~opt.flag_restart && ~isempty(qc_report{num_s+1,2})
        fprintf('    Skipping, QC report already completed\n',subject)            
        continue
    end        
    
    if isempty(qc_report{num_s+1,2})
        qc_tmp = { 'OK' , 'OK' , 'None' , 'OK' , 'None' };
    else
        qc_tmp = qc_report(num_s+1,2:end);
    end    
    
    %% Coregister raw anatomical scan with functional
    if ~isfield(files,subject)
        error('I could not find subject %s ',subject)
    end
    %% Loop over subject's sessions
    
        file_anat = char(files.(subject).anat); % The individual T1 scan
        file_func = char(files.(subject).fmri); % The individual Functional scan
    
        if ~psom_exist(file_anat)
            error('I could not find the anatomical scan %s for subject %s',file_anat,subject)
        end
        if ~psom_exist(file_func)
        error('I could not find the functional scan %s for subject %s',file_func,subject)
        end
    
        fprintf('    Individual T1 and Functional scan \n')
        [status,msg] = system(['register ' file_func ' ' file_anat ' &']);
        if status ~=0
           error('There was an error calling register. The error message was: msg')
        end
    
       % Get the input from the user for anatomical image
       flag_ok = false;
       while ~flag_ok
              fprintf('    Rate T1 scan Subject %s\n',subject)
              qc_input = input(sprintf('        ([O]K / [M]aybe / [F]ail), Default "%s": ',qc_tmp{2}),'s');
              flag_ok = ismember(qc_input,{'OK','O','Maybe','M','Fail','F',''});
              if ~flag_ok
                  fprintf('        The status should be O , M or F\n')
              end
       end
       switch qc_input
             case {'OK','O'}
                  qc_report{num_s+1,3} = 'OK';
             case {'Maybe','M'}
                  qc_report{num_s+1,3} = 'Maybe';
             case {'Fail','F'}
                  qc_report{num_s+1,3} = 'Fail';        
             case ''
                  qc_report{num_s+1,3} = qc_tmp{2};
       end
       flag_ok = false;
       while ~flag_ok
             qc_comment = input(sprintf('        Comment, Default "%s": ',qc_tmp{3}),'s');
             flag_ok = isempty(findstr(qc_comment,','));
             if ~flag_ok
                 fprintf('        No comma allowed\n')
             end
       end
       if isempty(qc_comment)
          qc_report{num_s+1,4} = qc_tmp{3};
       else
          qc_report{num_s+1,4} = qc_comment;
       end    
    
    
       % Get the input from the user for functional scan
       flag_ok = false;
       while ~flag_ok
              fprintf('    Rate Functional scan Subject %s\n',subject)
              qc_input = input(sprintf('        ([O]K / [M]aybe / [F]ail), Default "%s": ',qc_tmp{4}),'s');
              flag_ok = ismember(qc_input,{'OK','O','Maybe','M','Fail','F',''});
              if ~flag_ok
                  fprintf('        The status should be O , M or F\n')
              end
       end
       switch qc_input
           case {'OK','O'}
                qc_report{num_s+1,5} = 'OK';
           case {'Maybe','M'}
               qc_report{num_s+1,5} = 'Maybe';
           case {'Fail','F'}
               qc_report{num_s+1,5} = 'Fail';   
           case ''
               qc_report{num_s+1,5} = qc_tmp{4};
       end
       flag_ok = false;
       while ~flag_ok
           qc_comment = input(sprintf('        Comment, Default "%s": ',qc_tmp{5}),'s');
           flag_ok = isempty(findstr(qc_comment,','));
           if ~flag_ok
               fprintf('        No comma allowed\n')
           end
       end
       if isempty(qc_comment)
        qc_report{num_s+1,6} = qc_tmp{5};
       else
        qc_report{num_s+1,6} = qc_comment;
       end
    
       % Final status
       if strcmp(qc_report{num_s+1,3},'Fail')||strcmp(qc_report{num_s+1,5},'Fail')
          qc_report{num_s+1,2} = [' Fail'];
       elseif strcmp(qc_report{num_s+1,3},'Maybe')||strcmp(qc_report{num_s+1,5},'Maybe')
          qc_report{num_s+1,2} = [' Maybe'];
       else 
          qc_report{num_s+1,2} = [' OK'];
       end
    
       %% Save the report
       niak_write_csv_cell(file_qc,qc_report);
    end
end