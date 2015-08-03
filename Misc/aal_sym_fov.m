
%% A script to generate an AAL parcelation that is better adapted to the MNI 2009 symmetric
clear

%% Read volumes
path_aal = '/home/pbellec/database/templates/parcelation_niak/';
[hdr_aal,aal] = niak_read_vol([path_aal 'roi_aal_mni_2009_sym.mnc.gz']);

%% Create a slightly larger FOV to cover the ventral cerebellum
[nx,ny,nz] = size(aal);
[cos,step,start] = niak_hdr_mat2minc(hdr_aal.info.mat);
aal2 = zeros([nx,ny,nz+9]);
aal2(:,:,10:end) = aal;
start(3) = start(3) - 18;
file_aal = [path_aal 'roi_aal_mni_2009_sym_full.mnc.gz'];
hdr_aal.info.mat = niak_hdr_minc2mat(cos,step,start);
hdr_aal.file_name = file_aal;
niak_write_vol(hdr_aal,aal2);

%% Resample the grey matter PVE field at 3 mm
[hdr_gm,gm] = niak_read_vol([path_aal 'pve_gm.mnc.gz']);

%% Generate a mask
mask = aal2>0;
mask(:,:,1:20) = gm(:,:,1:20)>0.05;
[hdr_brain,brain] = niak_read_vol([path_aal 'mask_brain.mnc.gz']);
mask(~brain) = 0;
brain_erode = niak_morph(brain,'-successive EEE',opt_m);
brain(brain_erode>0) = 0;
mask(brain>0) = true;
opt_m.pad_size = 3;
mask = niak_morph(mask,'-successive DE',opt_m);
[hdr_atlas,atlas] = niak_read_vol([path_aal 'atlas_grey.mnc.gz']);
atlas = round(atlas);
atlas = atlas==20;
atlas = niak_morph(atlas,'-successive D',opt_m);
mask(atlas >0) = 0;
mask_flipped = mask(end:-1:1,:,:);
mask = mask | mask_flipped;
hdr_aal.file_name = [path_aal 'mask.mng.gz'];
niak_write_vol(hdr_aal,mask);

%% Generate individual binary volumes
aal = aal2;
list_aal = unique(aal(:));
list_aal = list_aal(list_aal~=0);
vol_roi = zeros([size(aal) length(list_aal)]);
for num_r = 1:length(list_aal)
    vol_roi(:,:,:,num_r) = aal==list_aal(num_r);
end

%% Smooth the binary volumes
opt_s.fwhm = 2.5;
opt_s.flag_edge = true;
vol_roi = niak_smooth_vol(vol_roi,opt_s);
file_smooth = [path_aal 'vol_roi.mat'];
save(file_smooth,'vol_roi');

%% Enforce symmetry in the labels
lab = load([path_aal 'labels_aal.mat']);
laal = lab.labels_aal;
vol_sym = zeros(size(vol_roi));
for num_l = 1:length(laal)
    if strcmp(laal{num_l}(end-1:end),'_L')
        olab = [laal{num_l}(1:(end-2)),'_R'];
        indo = find(ismember(laal,olab));
    elseif strcmp(laal{num_l}(end-1:end),'_R')
        olab = [laal{num_l}(1:(end-2)),'_L'];
        indo = find(ismember(laal,olab));
    else  
        indo = num_l;
    end
    fprintf('Labels %s was associated with %s\n',laal{num_l},laal{indo});
    vol_tmp = vol_roi(:,:,:,num_l);
    vol_tmp2 = vol_roi(:,:,:,indo);
    vol_tmp = max(vol_tmp,vol_tmp2(end:-1:1,:,:));
    vol_sym(:,:,:,num_l) = vol_tmp;
end
    
%% Propagate labels
[tmp,vol_max] = max(vol_sym,[],4);
vol_max = lab.rois_aal(vol_max);
aal_full = zeros(size(vol_max));
aal_full(mask) = vol_max(mask);

%% Manually fix the most ventral slices
tmp = aal_full(1:floor(size(aal_full,1)/2),:,1:4);
tmp(tmp>0) = 9061;
aal_full(1:floor(size(aal_full,1)/2),:,1:4) = tmp;
tmp = aal_full(floor(size(aal_full,1)/2)+1:end,:,1:4);
tmp(tmp>0) = 9062;
aal_full(floor(size(aal_full,1)/2)+1:end,:,1:4) = tmp;

%% Additional manual tweaks
[hdr,mane] = niak_read_vol([path_aal 'manual_edits.nii']);
mane = mane | mane(end:-1:1,:,:);
aal_full(mane) = 0;

%% remove small isolated spatial clusters by merging them with their largest spatial neighbour
list_aal = unique(aal_full);
list_aal = list_aal(list_aal~=0);
opt_c.type_neig = 26;
for num_a = 1:length(list_aal);
    mask = niak_find_connex_roi(aal_full==list_aal(num_a)); % Extract a binary mask of the AAL area
    sz_roi = niak_build_size_roi(mask); % derive the size of connected components
    if length(sz_roi)>1 % There is more than one component, merge the small ones with their neighbour
        fprintf('Huho there are %i spatially isolated cluster in AAL area %i with the following sizes:\n',length(sz_roi)-1,list_aal(num_a));        
        [val,ind] = max(sz_roi); % find the largest connected component
        to_merge = 1:length(sz_roi); 
        to_merge = to_merge(to_merge~=ind); % Get a list of the connected component that have to be merged
        sz_roi = sz_roi(to_merge);
        sz_roi(:)'       
        for num_m = 1:length(to_merge)
            mask_m = mask==to_merge(num_m); % Get a binary mask of the connected component to be merged
            mask_md = niak_morph(mask_m,'-dilation'); % dilate the component
            mask_md = mask_md>0;
            neig = unique(aal_full(mask_md)); % use the dilated mask to pick up the neighbours
            neig = neig(~ismember(neig,[0 list_aal(num_a)])); % exclude the AAL area itself as well as voxels outside of the grey matter
            sz_neig = zeros(length(neig),1);
            for num_n = 1:length(neig)
                sz_neig(num_n) = sum(aal_full(:)==neig(num_n));
            end
            [val_n,ind_n] = max(sz_neig);
            aal_full(mask_m) = neig(ind_n);
        end
    end
end
      
%% Write the final segmentation
hdr_aal.file_name = [path_aal 'roi_aal_mni_2009_sym_full.mnc.gz'];
niak_write_vol(hdr_aal,aal_full);

%% Resample at 3mm isotropic
files_in.source = [path_aal 'roi_aal_mni_2009_sym_full.mnc.gz'];
files_in.target = [path_aal 'roi_aal_mni_2009_sym_full.mnc.gz'];
files_out = [path_aal 'roi_aal_mni_2009_sym_full_3mm.mnc.gz'];
opt_r.voxel_size = [3 3 3];
opt_r.interpolation = 'nearest_neighbour';
niak_brick_resample_vol(files_in,files_out,opt_r);

