% open function/files with vim through octave 
function [status,output] = vim(func_name);
file_name  = which(func_name);
file_name  = strrep(file_name,' ','\ ');
envirement = sprintf ('echo $TMUX');
[out_env, text_env] = system (envirement);
IDX_env  = strfind (text_env,'tmux');
if isempty (IDX_env)
   command = sprintf('gnome-terminal -e "vim -f %s" &',file_name);
   else command = sprintf('tmux splitw -v "vim %s"',file_name); 
end
system(command,0,'async');