clear

%% Add quarantaine 
addpath(genpath('/usr/local/quarantine/niak-boss-0.12.14'));
niak_gb_vars

%% Folder names
path_res = '/media/database8/nki_enhanced/rmap_template_monkey/';
path_write = [path_res 'rmap_conn' filesep];
psom_mkdir(path_write);

%% Read subject list
file_network = [path_res 'network_rois.mnc.gz'];
[hdr,vol] = niak_read_vol(file_network);

%% Read connectomes
path_conn = [path_res 'connectomes' filesep];
list_conn = dir([path_conn 'connectome_rois*']);
list_conn = {list_conn.name};
list_seed = [121 128];
label_seed = {'aMPFC','PCC'};
for se = 1:length(label_seed)
    for ss = 1:length(list_conn)
        file_conn = [path_conn list_conn{ss}];
        data = load(file_conn);
        conn = niak_vec2mat(data.conn);
        if ss == 1
            rmap_vec = conn(:,data.ind_roi==list_seed(se));
        else 
            rmap_vec = rmap_vec + conn(:,data.ind_roi==list_seed(se));
        end
    end
    rmap_vec = rmap_vec / length(list_conn);

    %% Convert into volume
    rmap = zeros(size(vol));
    for rr = 1:length(data.ind_roi)
        rmap(vol==data.ind_roi(rr)) = rmap_vec(rr);
    end
    
    %% Write as a volume
    hdr.file_name = [path_write 'rmap_conn_' label_seed{se} '.mnc.gz'];
    niak_write_vol(hdr,rmap);
end