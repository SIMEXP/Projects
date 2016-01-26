niak_read_csv(FD);

rest1 = 0;
rest2 = 0;
tag = 'rest1';
expression = 's[0-9]*[A-Z]*';

for n = 1: length(labels_x)
    
    name = labels_x(n);
    a  =findstr(tag,name);
    
    if isempty(a)
        rest2 = rest2+1;
        table2(rest2,:) = table(n,:);
        matchStr = regexp(name,expression,'match');
        name_new = matchStr{1};
        table2(rest2,1) = name_new;
    else
        rest1 = rest1+ 1;
        table1(rest1,:) = table(n,:);
        matchStr = regexp(name,expression,'match');
        name_new = matchStr{1};
        table1(rest1,1) = name_new;
    end
end

niak_write_csv(FD1)
niak_write_csv(FD2)