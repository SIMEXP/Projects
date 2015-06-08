% Template to write a script for the NIAK fMRI preprocessing pipeline
% ADAPTED TO THE RANN DATASET (Perrine Ferre) 2015 05 05_TEST
%
% To run a demo of the preprocessing, please see
% NIAK_DEMO_FMRI_PREPROCESS.
%
% Copyright (c) Pierre Bellec, 
%   Montreal Neurological Institute, McGill University, 2008-2010.
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Quebec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, preprocessing, pipeline

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



root_path = '/gs/project/gsf-624-aa/RANN';
path_out = '/gs/scratch/pferre/RANN/';

%% Grab the raw data
path_raw = [root_path 'raw_mnc/'];
list_subject = dir(path_raw);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..'}));


for num_s = 1%:length(list_subject)
    subject = list_subject{num_s};
    files_in.(subject).anat = [path_raw subject filesep 'T1' filesep 'T1_' subject '_*.mnc.gz'];
    files_in.(subject).fmri.sess1.ant = [path_raw subject filesep 'Ant_r1_' subject '_*.mnc.gz'];
    files_in.(subject).fmri.sess1.syn = [path_raw subject filesep 'Syn_r1_' subject '_*.mnc.gz'];
    files_in.(subject).fmri.sess1.pictname = [path_raw subject filesep 'PictName_r1_' subject '_*.mnc.gz'];    
    files_in.(subject).fmri.sess1.rest = [path_raw subject filesep 'REST_BOLD_' subject '_*.mnc.gz']; 
    
    files_c = psom_files2cell(files_in.(subject).fmri.sess1);
    for num_f = 1:length(files_c)
        if ~psom_exist(files_c{num_f})
            warning ('The file %s does not exist, I suppressed that file from the pipeline %s',files_c{num_f},subject);
            files_in.(subject).fmri.sess1 = rmfield(files_in.(subject).fmri.sess1,fieldnames(files_in.(subject).fmri.sess1)(num_f));
            break
        end        
    end
    
    
    files_c = psom_files2cell(files_in.(subject).anat);
    for num_f = 1:length(files_c)
        if ~psom_exist(files_c{num_f})
            warning ('The file %s does not exist, I suppressed that subject %s',files_c{num_f},subject);
            files_in = rmfield(files_in,subject);
            break
        end        
    end
    
    
end


