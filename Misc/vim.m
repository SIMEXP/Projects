% open function/files with vim through octave 
function [status,output] = vim(func_name);
file_name  = which(func_name);
file_name  = strrep(file_name,' ','\ ');
terminal   = sprintf('echo $TERM');
envirement = sprintf ('echo $TMUX');
[out_term, text_term] = system (terminal);
[out_env, text_env] = system (envirement);
IDX_env  = strfind (text_env,'tmux');
IDX_term = strfind (text_term,'xterm');
if isempty(IDX_term)
   if isempty (IDX_env)
      command = sprintf('gnome-terminal -e "vim -f %s" &',file_name);
   else command = sprintf('tmux splitw -v "vim %s"',file_name); 
   end
else command = sprintf('xterm -e "vim -f %s" &',file_name);
end
[status,output] = system(command,0,'async');