function cell_combin = combine_cell_tab(cell_master,cell_slave,opt)
% Search and Combine matching cell table's rows ( One master celll table and one slave)
%
% SYNTAX:
% CSV_CELL_COMBINE = COMBINE_CELL_TAB(CELL_MASTER,CELL_SLAVE,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% CELL_MASTER     
%       (cell of string) the cell table that is used as master
% 
% CELL_SLAVE     
%       (cell of string) the cell table that is used as slave
% 
% OPT
%   (structure, optional) with the following fields:
%
%   HEADER
%       (boolean, default true) the first rows are the table's headers.
%
%   COMBINE_MASTER_COLOMN
%       (number, default '1') choose wich colomn to use as reference for combininng with salve.
%
%   COMBINE_SLAVE_COLOMN
%       (number, default '1') choose wich colomn to use as reference for combininng with master.
%
% _________________________________________________________________________
% OUTPUTS:
%
% CELL_COMBINE
%   (cell of strings) CELL{i,j} is a string corresponding to the ith row
%   and jth column of the Master cell tab combined with the corresponding ith row
%   and jth column of the Slave cell tab.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_WRITE_CSV_CELL
% NIAK_READ_CSV_CELL
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Yassine Benhajali, Pierre Bellec,
% Centre de recherche de l'institut de griatrie de Montral, 
% Department of Computer Science and Operations Research
% University of Montreal, Qubec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : table, CSV

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

%% Set Default inputs
if ~exist('cell_master','var')||~exist('cell_slave','var')
    error('Please specify CELL_MASTER and CELL_SLAVE as inputs');
end

%% Set default options
list_fields   = {'header' , 'combine_master_colomn' , 'combine_slave_colomn' };
list_defaults = { true    , 1                       , 1                      };
if nargin == 2
   opt = psom_struct_defaults(struct(),list_fields,list_defaults);
else 
   opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

% Loop over ID's and combine master with slave
cell_combin = cell(size(cell_master,1),size(cell_slave,2)+size(cell_master,2));
n_shift = 0;
for n_cell_master = 2:size(cell_master(1:end,opt.combine_master_colomn),1)
    niak_progress( n_cell_master , length(cell_master(1:end,opt.combine_master_colomn)))
    n_rep = 0;
    for n_cell_slave = 2:size(cell_slave(1:end,opt.combine_slave_colomn),1)
        subj_match = strfind(cell_master{n_cell_master,opt.combine_master_colomn},char(cell_slave{n_cell_slave,opt.combine_slave_colomn}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              cell_combin(n_cell_master + n_shift,:) = [ cell_master(n_cell_master,:)  cell_slave(n_cell_slave,:) ];
           else
              cell_combin(n_cell_master + n_shift,:) = [ cell_master(n_cell_master,:)  cell_slave(n_cell_slave,:) ];
           end
        end
    end
    if n_rep == 0
    cell_combin(n_cell_master + n_shift ,:) = [ cell_master(n_cell_master,:) cell(size(cell_slave(n_cell_slave,:)))  ];
    end
end
cell_combin(cellfun(@isempty,cell_combin))=NaN;

% add tables headers
cell_combin(1,:) = [ cell_master(1,:)  cell_slave(1,:) ];