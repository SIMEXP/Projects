function [status,output] = kate(func_name);

file_name = which(func_name);
file_name = strrep(file_name,' ','\ ');
system(['kate ' file_name ' 1>/dev/null 2>/dev/null'],0,'async');