clear

path = '/Users/pyeror/Work/transfert/Brainspell/maps_results/';
output = '/Users/pyeror/Work/transfert/Brainspell/maps_results/matching/';

contrast = {'MCI_decrease','MCI_increase','AD_decrease','AD_increase'};

cluster = 'template_cambridge_basc_multiscale_sym_scale007';
subcluster = 'template_cambridge_basc_multiscale_sym_scale036';


% Create ouptut directory
psom_mkdir(output)


% Subclusters
files_in.cluster = [path cluster '.nii.gz'];
files_in.subcluster = [path subcluster '.nii.gz'];
files_out.subcluster = [];
files_out.matching = [];
opt.folder_out = path;
niak_brick_subclusters(files_in,files_out,opt)


% Matching
for c = 1:length(contrast)
    
    [hdr,vol] = niak_read_vol([path contrast{c} '_hitfreq_scale36_vol.nii.gz']);
    load template_cambridge_basc_multiscale_sym_scale007_matching
    
    % plots
    load([path contrast{c} '_scale7_stats'])
    figure
    bar(Hits)
    axis([0 8 0 70])
    namefig = [path contrast{c} '_scale7_hits'];
    print(namefig,'-dpdf','-r300')
    close all
    
    for n = 1:7
        % vols
        [hdr,atlas] = niak_read_vol([path cluster '_clust' num2str(n) '.nii.gz']);
        subvol = vol;
        subvol(atlas<1) = 0;
        hdr.file_name = [output contrast{c} '_hitfreq_scale36_clust' num2str(n) '.nii.gz'];
        niak_write_vol(hdr,subvol);
        
%         % plots
%         index = matching{n};
%         for i = 1:length(index)
%             
%         TO BE CONTINUED TO REARRANGE STATS.MAT FILES ACCORDING TO
%         SUBCLUSTERING
%           
    end    
end



