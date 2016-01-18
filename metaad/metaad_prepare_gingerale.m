clear

%% Paths
path_data = '/home/pbellec/Desktop/Meta_analyses_tables/';
path_out = '/home/pbellec/Desktop/metaad_gingerale/';
psom_mkdir(path_out);

%% Parameters
contrast = 'AD'; % AD , MCI
label_contrast = 'AD minus CN'; % AD minus CN, MCI minus CN
type = 'd'; % i, d
label_type = 'decrease'; % incrase, decrease

%% Files
file_table = [path_data 'Table.csv'];
files = dir([path_data '*' contrast '*' type '.csv']);
files = {files.name};
file_out = [path_out contrast type '.txt'];

%% Read the main table
%data_table = niak_read_csv_cell(file_table);

hf = fopen(file_out,'w');
for ff = 1:length(files)
    pubmed_id = files{ff}(1:8);
    file_name = [path_data files{ff}];
    data = niak_read_csv_cell(file_name);
    year = '1999';
    N = '20';
    author = 'Li';
    space = 'Talairach';
    title = 'AD paper';
    
    %% Space of reference
    fprintf(hf,'// Reference = %s\n',space);
    fprintf(hf,'// %s, %s: %s, %s\n',author,year,label_contrast,label_type);
    fprintf(hf,'// Subjects=%s\n',N);
    for cc = 2:size(data,1)
        fprintf(hf,'%s     %s     %s\n',data{cc,2},data{cc,3},data{cc,4});
    end
    fprintf(hf,'\n');
end
fclose(hf)