function [] = hcp_build_ind_onset_motor(path_folder,opt)
%% function to generate onset file per subject
%
% SYNTAX:
% [] = IND_ONSET_MOTOR_CSV(OPT)
%
% _________________________________________________________________________
% PATH_FOLDER (string, default [pwd]) the full path to the root folder that contain the 
%   individual HCP EV's variables. 
%
% OPT
%   (structure, optional) with the following fields :
%
%   RUN (string, default 'lr') type of run that would be extracted, possiblr trial : 'lr', 'rl'.

%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%
path_folder = niak_full_path (path_folder);

%% Default options
list_fields   = { 'run'};
list_defaults = { 'lr' };
if (nargin > 1) && ~isempty(opt.run) 
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end


%% intrarun onset build
switch opt.run
     case 'lr'
        opt_csv_read.separator= sprintf('\t');
        onset_intrarun_names = {opt.run,'start'};
        onset_intrarun_cond  = {'cue','rh','cue','lf','cue','t','cue','rf','cue','lh','rest','cue','t','cue','lf','cue','rh','rest','cue','lh','cue','rf','rest'};
        onset_intrarun_values(1,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){1,1});
        onset_intrarun_values(2,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){1,1});
        onset_intrarun_values(3,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){2,1});
        onset_intrarun_values(4,1) = str2num(niak_read_csv_cell([path_folder 'lf.txt'],opt_csv_read){1,1});
        onset_intrarun_values(5,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){3,1});
        onset_intrarun_values(6,1) = str2num(niak_read_csv_cell([path_folder 't.txt'],opt_csv_read){1,1});
        onset_intrarun_values(7,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){4,1});
        onset_intrarun_values(8,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){1,1});
        onset_intrarun_values(9,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){5,1});
        onset_intrarun_values(10,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){1,1});
        onset_intrarun_values(11,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){1,1})+12;
        onset_intrarun_values(12,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){6,1});
        onset_intrarun_values(13,1) = str2num(niak_read_csv_cell([path_folder 't.txt'],opt_csv_read){2,1});
        onset_intrarun_values(14,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){7,1});
        onset_intrarun_values(15,1) = str2num(niak_read_csv_cell([path_folder 'lf.txt'],opt_csv_read){2,1});
        onset_intrarun_values(16,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){8,1});
        onset_intrarun_values(17,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){2,1});
        onset_intrarun_values(18,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){2,1})+12;
        onset_intrarun_values(19,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){9,1});
        onset_intrarun_values(20,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){2,1});
        onset_intrarun_values(21,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){10,1});
        onset_intrarun_values(22,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){2,1});
        onset_intrarun_values(23,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){2,1})+12;
case 'rl' %WARNING: this section is not completed
        opt_csv_read.separator= sprintf('\t');
        onset_intrarun_names = {opt.run,'start'};
        onset_intrarun_cond  = {'cue','lh','cue','rf','cue','t','cue','rf','cue','lh','rest','cue','t','cue','lf','cue','rh','rest','cue','lh','cue','rf','rest'};
        onset_intrarun_values(1,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){1,1});
        onset_intrarun_values(2,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){1,1});
        onset_intrarun_values(3,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){2,1});
        onset_intrarun_values(4,1) = str2num(niak_read_csv_cell([path_folder 'lf.txt'],opt_csv_read){1,1});
        onset_intrarun_values(5,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){3,1});
        onset_intrarun_values(6,1) = str2num(niak_read_csv_cell([path_folder 't.txt'],opt_csv_read){1,1});
        onset_intrarun_values(7,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){4,1});
        onset_intrarun_values(8,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){1,1});
        onset_intrarun_values(9,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){5,1});
        onset_intrarun_values(10,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){1,1});
        onset_intrarun_values(11,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){1,1})+12;
        onset_intrarun_values(12,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){6,1});
        onset_intrarun_values(13,1) = str2num(niak_read_csv_cell([path_folder 't.txt'],opt_csv_read){2,1});
        onset_intrarun_values(14,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){7,1});
        onset_intrarun_values(15,1) = str2num(niak_read_csv_cell([path_folder 'lf.txt'],opt_csv_read){2,1});
        onset_intrarun_values(16,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){8,1});
        onset_intrarun_values(17,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){2,1});
        onset_intrarun_values(18,1) = str2num(niak_read_csv_cell([path_folder 'rh.txt'],opt_csv_read){2,1})+12;
        onset_intrarun_values(19,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){9,1});
        onset_intrarun_values(20,1) = str2num(niak_read_csv_cell([path_folder 'lh.txt'],opt_csv_read){2,1});
        onset_intrarun_values(21,1) = str2num(niak_read_csv_cell([path_folder 'cue.txt'],opt_csv_read){10,1});
        onset_intrarun_values(22,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){2,1});
        onset_intrarun_values(23,1) = str2num(niak_read_csv_cell([path_folder 'rf.txt'],opt_csv_read){2,1})+12;

end
opt_csv_write.labels_y = onset_intrarun_names;
opt_csv_write.labels_x = onset_intrarun_cond;
opt_csv_write.precision = 2;
niak_write_csv(strcat(dir_output,name_csv_intrarun,'.csv'),onset_intrarun_values,opt_csv_write);

