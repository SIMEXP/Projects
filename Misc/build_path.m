function [] = build_path(names,varargin)
% This function adds some libraries in the matlab search path. 
%
% SYNTAX:
% [] = BUILD_PATH(NAMES)
%
% _________________________________________________________________________
% INPUTS : 
% 
% NAMES
%       (cell of strings) a list of library names
%
% _________________________________________________________________________
% OUTPUTS : 
%
% none
%
% _________________________________________________________________________
% COMMENTS
%
% The paths associated to the specified libraries are added to the matlab 
% search path *along with all subfolders*.
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : path, sorbier

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

if ischar(names)&&strcmp(names,'std')
    names = {'niak','psom','projects'};
elseif ischar(names)
    names = [{names} varargin(:)'];
end

%% Find available libraries
path_git = [getenv('HOME') filesep 'git' filesep];
list_libraries = dir(path_git);

nb_lib = 0;
for ll = 1:length(list_libraries)
    if list_libraries(ll).isdir&&~ismember(list_libraries(ll).name,{'.','..'})
        nb_lib = nb_lib+1;
        libraries(nb_lib).label = list_libraries(ll).name;
        libraries(nb_lib).path = [path_git list_libraries(ll).name];
    end
end

%% Add libraries to the path        
if nargin<1
    fprintf('Available libraries : ');
    for num_e = 1:length(libraries)
        fprintf('%s ; ',libraries(num_e).label)
    end
    fprintf('\n')
    return
end

%% Checking for the existence of the libraries
for num_n = 1:length(names)
    
    ind = find(ismember({libraries.label},names{num_n}));

    if isempty(ind)
        error(sprintf('No library correspond to the label %s ... cannot proceed !',names{num_n}))
    else
        if ~exist(libraries(ind(1)).path,'dir')
            error(sprintf('Could not add library %s : the path %s does not exist !',names{num_n},libraries(ind(1)).path));
        end
    end
    
   
end

%% Adding libraries to the path
for num_n = 1:length(names)
    
    ind = find(ismember({libraries.label},names{num_n}));
    disp(sprintf('Adding library %s to the search path.\n',libraries(ind).label));
    P = genpath(libraries(ind(1)).path);
    addpath(P);
        
end
