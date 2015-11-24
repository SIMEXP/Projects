function files_in = niak_purge_files_in (files_in)
% Remove non existing files and subject from the files_in structure:
% *If subject is missing ant files he will be dicarded 
% *If subject is missing all functional files he will be discarded
% *Any run or ssession misssing will be removed from the sctructues  
%
% SYNTAX:
% FILES_IN = NIAK_PURGE_FILES_IN(FILES_IN)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN (structure) with the following fields : 
%
%   <SUBJECT>.FMRI.<SESSION>.<RUN>
%       (string) a list of fMRI datasets, acquired in the same 
%       session (small displacements). 
%       The field names <SUBJECT>, <SESSION> and <RUN> can be any arbitrary 
%       strings.
%
%   <SUBJECT>.ANAT 
%       (string) anatomical volume, from the same subject as in 
%       FILES_IN.<SUBJECT>.FMRI
% _________________________________________________________________________
% OUTPUTS : 
%
%   FILES_IN 
%       (structure) cleaned files_in structur.
%      
% _________________________________________________________________________
%% Copyright (C) 2015 Pierre Bellec, Yassine Behajali
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
%% Author: yassinebha <yanamarji@gmail.com>
%% Created: 2015-11-24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check exixstense of fmri and anat field
list_id= fieldnames(files_in);
for ff=1:length(list_id) 
    field_fmri_ok(ff) = isfield(files_in.(list_id{ff}),'fmri');
    field_anat_ok(ff) = isfield(files_in.(list_id{ff}),'anat');
end
if any(~field_fmri_ok)||any(~field_anat_ok)
   error('missig one or some anat/fmri fields in the files_in structure')
end

%Loop over subjects sessions runs and remove non existent files_in
for num_id=1:length(list_id)
    id = list_id{num_id};
    list_session = fieldnames(files_in.(id).fmri);
    flag_ok_stack = [];
    for num_sess = 1:length(list_session) % Sessions
        session = list_session{num_sess};
        list_run = fieldnames(files_in.(id).fmri.(session));
        eval( [ 'flag_ok_' session ' = true(length( list_run ),1);']);
        for num_f = 1:length(list_run) % Runs
            run = list_run{num_f};
            if ~psom_exist(files_in.(id).fmri.(session).(run))
               eval( [ 'flag_ok_' session '(num_f ) = false;' ]);
            end        
        end
        flag_ok_stack = [flag_ok_stack ; eval( [ 'flag_ok_' session ])];
    end
    flag_ok = flag_ok_stack;
    if ~any(flag_ok)||~psom_exist(files_in.(id).anat)
       if ~any(flag_ok)
          warning('No functional data for subject %s, I suppressed it',id);
       else
          warning ('The anat file %s does not exist, I suppressed that subject %s',files_in.(id).anat,id);
       end
       files_in = rmfield(files_in,id);
    elseif any(~flag_ok)
       for num_sess = 1:length(list_session) 
           session = list_session{num_sess};
           flag_ok_tmp = eval( [ 'flag_ok_' session ';']);
           list_run = fieldnames(files_in.(id).fmri.(session));
           if ~any(~flag_ok_tmp)
              continue
           else    
              list_run = fieldnames(files_in.(id).fmri.(session));
              files_in.(id).fmri.(session) = rmfield(files_in.(id).fmri.(session),list_run(~flag_ok_tmp));
              warning ('I suppressed the following runs for subject %s because the files were missing:',id);
              list_not_ok = find(~flag_ok_tmp);
              for ind_not_ok = list_not_ok(:)'
                  fprintf(' %s',list_run{ind_not_ok});
              end
              fprintf('\n')
           end    
       end
    end
end    
endfunction
