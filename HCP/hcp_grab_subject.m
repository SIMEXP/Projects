% grab subject from each of the five HCP discs

for nn = 1:4 
    path_data = ['/media/S500-' num2str(nn) '-20140805/'];
    opt.path_out = '/media/database1/';
    opt.type_task = 'EMOTION';
    niak_extract_preprocessed_hcp(path_data,opt);
end

opt.path_out = '~/Desktop/';
opt.type_task = 'EMOTION';
path_data = '/media/database1/hcp/';