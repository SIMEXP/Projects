

%% create correlation matrix at the voxel level
output_folder = '/data/cisl/cdansereau/multisite/fcon1000_corrmatrix/';
mkdir(output_folder);
site_names = {'Baltimore'  ,'Berlin',  'Cambridge'  ,'Newark'  ,'NewYork_b'  ,'Oxford','Queensland','SaintLouis'};

%% we will use a mask based on the cambridge dataset (database7/multisite/region_growing_cambridge_05scrubb/rois/bain_rois.mnc.gz)
[h,part] = niak_read_vol('/data/cisl/cdansereau/multisite/region_growing_cambridge_05scrubb_216mm/rois/brain_rois.mnc.gz');

for sn = 1:size(site_names,2)
    
    % load 
    tmp_path = ['/data/cisl/cdansereau/scrubbing/fcon_1000_preprocess/' site_names{sn} '/fmri_preprocess_05scrubb/fmri/'];
    subjlist = dir([tmp_path '*.mnc.gz']);
    for subjidx = 1:size(subjlist,1)
        R=[];
        subj_id = subjlist(subjidx).name(6:13);
        [h,vol]=niak_read_vol([tmp_path subjlist(subjidx).name]);
        opt_ts.correction='mean';
        ts = niak_build_tseries(vol,part,opt_ts);
        R = corrcoef(ts);
        %R = (R-median(R))/niak_mad(R); 
        Z = niak_fisher(R);
	
        
        %save 
        save([output_folder 'corrmatrix_' subj_id '.mat'],'-v7.3','R','Z','subj_id');
    end
    
end









