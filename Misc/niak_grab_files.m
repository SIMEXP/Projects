function files = niak_grab_files(path_s)
% Syntax: FILES = NIAK_GRAB_FOLDER(PATH_S)
% PATH_S (string) a folder name with full path
% FILES(I).NAME (string) the name of a file (full path)
% FILES(I).SIZE (scalar) the size of the file, in bytes
%
% This function will grab all files recursively in PATH_S. 
% (c) Pierre Bellec, MIT license 2015. See affiliations and licence
% info in README.md
path_s = niak_full_path(path_s);
files_struct = dir(path_s);
files = struct([]);
ee = 1;
for ff = 1:length(files_struct)
    if ~files_struct(ff).isdir
        files(ee).name = [path_s files_struct(ff).name];
        files(ee).size = files_struct(ff).bytes;
        ee = ee+1;
    elseif files_struct(ff).isdir && ~strcmp(files_struct(ff).name,'.') && ~strcmp(files_struct(ff).name,'..')  
        files = [files niak_grab_files([path_s files_struct(ff).name])];
    end
end