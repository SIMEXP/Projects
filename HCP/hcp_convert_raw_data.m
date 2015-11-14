## Copyright (C) 2015 Yassine
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Yassine <yassinebha@d085971c34b8>
## Created: 2015-11-13

clear all
%% Setting input/output files 
[status,cmdout] = system ('uname -n');
server          = strtrim(cmdout);
if strfind(server,'lg-1r') % This is guillimin
    root_path = '/gs/project/gsf-624-aa/HCP/';
    path_raw  = [ root_path '/HCP_raw_data/'];
    fprintf ('server: %s (Guillimin) \n ',server)
    my_user_name = getenv('USER');
elseif strfind(server,'ip05') % this is mammouth
    root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2015/pbellec/benhajal/HCP/';
    path_raw = [root_path 'HCP_unproc_tmp/'];
    fprintf ('server: %s (Mammouth) \n',server)
    my_user_name = getenv('USER');
else
    switch server
        case 'peuplier' % this is peuplier
        root_path = '/media/scratch2/HCP_unproc_tmp/';
        path_raw = [root_path 'HCP_unproc_tmp/'];
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
        
        case 'noisetier' % this is noisetier
        root_path = '/media/database1/';
        path_raw = [root_path 'HCP_unproc_tmp/'];
        fprintf ('server: %s\n',server)
        my_user_name = getenv('USER');
    end
end


list_task = {'EMOTION', 'GAMBLING','LANGUAGE','MOTOR','RELATIONAL','SOCIAL','WM','REST1','REST2'}:
list_run = {'LR' , 'RL'};
path_nii = path_raw ;
path_mnc = [ root_path  'HCP_raw_mnc/' ];
opt_pipe.path_logs = [path_mnc 'logs_conversion'];
list_subject = dir(path_nii);
list_subject = {list_subject(3:end).name};
nb_subject = length(list_subject);
%nb_subject = 2;
pipeline = struct();
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_sub = [path_nii subject filesep];
    path_read.func = [path_sub 'unprocessed/3T/'];
    path_read.anat = [path_sub 'unprocessed/3T/T1w_MPR1/'];
    path_write.anat = [path_mnc subject filesep 'MPR_1' filesep];
    for num_r = 1:length(list_run)
          run = list_run{num_r};
          for num_t = 1:length(list_task)
              task = list_task{num_t};
              fprintf('    Task  %s_%s\n', task , run);
              path_write.func = [path_mnc subject filesep task filesep];
              path_tmp = [path_mnc subject filesep task filesep 'tmp' filesep];
              name_job = subject ;
              name_job = sprintf('%s_task%s_%s',name_job,num_t,num_r);
              pipeline.(name_job).files_out.tmp  = path_tmp;
              if num_t == 1 && num_r == 1
                files_out.anat = [path_write.anat 'anat_' subject '_' task 'mnc'];
                files_out.func = [path_write.func 'func_' subject '_' task '_' lower(run) '.mnc'];
                pipeline.(name_job).instr_conv = ['nii2mnc ' path_tmp ' -f nifti -n -u fnformat=-PatientId+PatientName+SequenceName ' path_read];
                pipeline.(name_job).command        = 'system(opt.instr_conv); twi_mosaic2vol(files_out.tmp,files_out.func,files_out.anat);';        
                pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
              else
                pipeline.(name_job).files_out.anat = [path_write.anat 'anat_' subject '_' task 'mnc'];   
                pipeline.(name_job).files_out.func = [path_write.func 'func_' subject '_' task '_' lower(run) '.mnc'];
                pipeline.(name_job).opt.instr_conv = ['mcverter -o ' path_tmp ' -f nifti -n -u fnformat=-PatientId+PatientName+SequenceName ' path_read];
                pipeline.(name_job).command        = 'system(opt.instr_conv); twi_mosaic2vol(files_out.tmp,files_out.func,files_out.anat);';        
                pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
              end
          end
    end 
end
psom_run_pipeline(pipeline,opt_pipe)
