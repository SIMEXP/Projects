%% Copyright (C) 2015 Yassine
%% 
%% This program is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%
%% Author: Yassine <yassinebha@d085971c34b8>
%% Created: 2015-11-13

clear all
niak_gb_vars
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

% set path and variables
list_task = {'EMOTION', 'GAMBLING','LANGUAGE','MOTOR','RELATIONAL','SOCIAL','WM','REST1','REST2'};
list_run = {'LR' , 'RL'};
path_nii = path_raw ;
path_mnc = [ root_path  'HCP_raw_mnc/' ];
opt_pipe.path_logs = [path_mnc 'logs_conversion'];
list_subject = dir(path_nii);
list_subject = {list_subject(3:end).name};
nb_subject = length(list_subject);
pipeline = struct();

% loop over subject
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_sub = [path_nii subject filesep];
    path_read_func = [path_sub 'unprocessed/3T/'];
    path_read_anat1 = [path_sub 'unprocessed/3T/T1w_MPR1/'];
    path_read_anat2 = [path_sub 'unprocessed/3T/T1w_MPR2/'];
    path_write_anat1 = [path_mnc subject filesep 'MPR_1' filesep];
    path_write_anat2 = [path_mnc subject filesep 'MPR_2' filesep];
    niak_mkdir(path_write_anat);
    path_tmp = [path_mnc subject '/tmp'];
    niak_mkdir(path_tmp);
    % loop over runs
    for num_r = 1:length(list_run)
          run = list_run{num_r};
          % loop over tasks
          for num_t = 1:length(list_task)
              task = list_task{num_t};
              fprintf('    Task %s_%s\n', task , run);
              path_write_func = [path_mnc subject filesep task filesep];
              niak_mkdir(path_write_func);
              name_job = sprintf('HCP_%s_%s_%s',subject,task,run);
              if num_t == 1 && num_r == 1 % if first iteration, run conversion for anat and functional image
                target_file_anat1 = [path_write_anat1 'anat_' subject '_MPR1.mnc'];
                target_file_anat2 = [path_write_anat2 'anat_' subject '_MPR2.mnc'];
                target_file_func = [path_write_func 'func_' subject '_' task '_' lower(run) '.mnc'];
                if ismember(task,{'REST1','REST2'})
                  prefix_fold = 'rfMRI_';
                else
                  prefix_fold = 'tfMRI_';
                end
                source_file_anat1 = [ path_read_anat1 subject '_3T_T1w_MPR1.nii'];
                source_file_anat2 = [ path_read_anat2 subject '_3T_T1w_MPR2.nii'];
                source_file_func = [ path_read_func prefix_fold upper(task) '_' upper(run) '/' subject '_3T_' prefix_fold upper(task) '_' upper(run) '.nii']; 
                tmp_file_anat1 = [path_mnc subject  niak_file_tmp('.nii')];
                tmp_file_anat2 = [path_mnc subject  niak_file_tmp('.nii')];
                tmp_file_func = [path_mnc subject niak_file_tmp('.nii')];
                instr_cp_anat1 = ['cp ' source_file_anat1 gb_niak_zip_ext ' ' tmp_file_anat1 gb_niak_zip_ext ];
                instr_cp_anat2 = ['cp ' source_file_anat2 gb_niak_zip_ext ' ' tmp_file_anat2 gb_niak_zip_ext ];
                instr_cp_func = ['cp ' source_file_func gb_niak_zip_ext ' ' tmp_file_func gb_niak_zip_ext ];
                instr_unzip_anat1 = [gb_niak_unzip ' ' tmp_file_anat1 gb_niak_zip_ext];
                instr_unzip_anat2 = [gb_niak_unzip ' ' tmp_file_anat2 gb_niak_zip_ext];
                instr_unzip_func = [gb_niak_unzip ' ' tmp_file_func gb_niak_zip_ext];
                instr_nii2mnc_anat1 = ['nii2mnc ' tmp_file_anat1 ' ' target_file_anat1];
                instr_nii2mnc_anat2 = ['nii2mnc ' tmp_file_anat2 ' ' target_file_anat2];
                instr_nii2mnc_func = ['nii2mnc ' tmp_file_func ' ' target_file_func];
                instr_rm_tmp_anat1 = ['rm ' tmp_file_anat1];
                instr_rm_tmp_anat2 = ['rm ' tmp_file_anat2];
                instr_rm_tmp_func = ['rm ' tmp_file_func];
                instr_zip_anat1 = ['gzip ' target_file_anat1];
                instr_zip_anat2 = ['gzip ' target_file_anat2];
                instr_zip_func = ['gzip ' target_file_func];
                instr_rm_extra_anat1 = ['rm ' target_file_anat1];
                instr_rm_extra_anat2 = ['rm ' target_file_anat2];
                instr_rm_extra_func = ['rm ' target_file_func];
                instr_final_anat1 = [instr_cp_anat1 ';' instr_unzip_anat1 ';' instr_nii2mnc_anat1 ';' instr_rm_tmp_anat1 ';' instr_zip_anat1 ';' instr_rm_extra_anat1];
                instr_final_anat2 = [instr_cp_anat2 ';' instr_unzip_anat2 ';' instr_nii2mnc_anat2 ';' instr_rm_tmp_anat2 ';' instr_zip_anat2 ';' instr_rm_extra_anat2];
                instr_final_func = [instr_cp_func ';' instr_unzip_func ';' instr_nii2mnc_func ';' instr_rm_tmp_func ';' instr_zip_func ';' instr_rm_extra_func];
                pipeline.(name_job).opt.instr_conv_anat1 = instr_final_anat1;
                pipeline.(name_job).opt.instr_conv_anat2 = instr_final_anat2;
                pipeline.(name_job).opt.instr_conv_func = instr_final_func;
                pipeline.(name_job).command = 'system(opt.instr_conv_anat1);system(opt.instr_conv_anat1); system(opt.instr_conv_func)';        
                %pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
              else % else run only functional conversion
                target_file_func = [path_write_func 'func_' subject '_' task '_' lower(run) '.mnc'];
                if ismember(task,{'REST1','REST2'})
                  prefix_fold = 'rfMRI_';
                else
                  prefix_fold = 'tfMRI_';
                end
                source_file_func = [ path_read_func prefix_fold upper(task) '_' upper(run) '/' subject '_3T_' prefix_fold upper(task) '_' upper(run) '.nii']; 
                tmp_file_func = [path_mnc subject niak_file_tmp('.nii')];
                instr_cp_func = ['cp ' source_file_func gb_niak_zip_ext ' ' tmp_file_func gb_niak_zip_ext ];
                instr_unzip_func = [gb_niak_unzip ' ' tmp_file_func gb_niak_zip_ext];
                instr_nii2mnc_func = ['nii2mnc ' tmp_file_func ' ' target_file_func];
                instr_rm_tmp_func = ['rm ' tmp_file_func];
                instr_zip_func = ['gzip ' target_file_func];
                instr_rm_extra_func = ['rm ' target_file_func];
                instr_final_func = [instr_cp_func ';' instr_unzip_func ';' instr_nii2mnc_func ';' instr_rm_tmp_func ';' instr_zip_func ';' instr_rm_extra_func];
                pipeline.(name_job).opt.instr_conv_func = instr_final_func;
                pipeline.(name_job).command = 'system(opt.instr_conv_func)';        
                %pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
              end
          end
    end 
end
psom_run_pipeline(pipeline,opt_pipe)