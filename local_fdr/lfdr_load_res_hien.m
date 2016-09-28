function [tab,lx,ly] = lfdr_load_res_hien(file_name)

[tab,lx,ly] = niak_read_csv(file_name);

ind_conn = zeros(length(lx),1);
for cc = 1:length(ind_conn)
    niak_progress(cc,length(ind_conn));
    ind_conn(cc) = str2num(lx{cc}(2:end));
end
[val,order] = sort(ind_conn);
tab = tab(order,:);
lx = lx(order);
