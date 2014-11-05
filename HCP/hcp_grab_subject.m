% grab subject from each of the five HCP discs

path_data = '/media/S500-1-20140805/';

opt.path_out = '/media/database1/';

opt.type_task = 'EMOTION';

niak_extract_preprocessed_hcp(path_data,opt);