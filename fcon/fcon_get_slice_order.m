function [slice_order] = fcon_get_slice_order(file,order,nb_slices,first);

% Gets the slice order to be used in the fcon_fmri_preprocess.
% 
% [slice_order] = fcon_get_slice_order(file,order,nb_slices,first)
% 
% IN:
%   file:
%     A file to get the zstep of the database. Use Nifti or Minc file.
%   order:
%     The name of the order used. See fcon_get_infos for more information.
%   nb_slices:
%     The number of slices used. See fcon_get_infos for more information.
%   first:
%     The first number in text format between odd and even. See fcon_get_infos for more information.
% 
% OUT:
%   slice_order:
%     The slice order of the database in an array format.
% 

if ~exist(file,'file')
  error(cat(2,'Could not find specified file : ',file));
end

hdr = niak_read_vol(file);
[mat,step,start] = niak_hdr_mat2minc(hdr.info.mat);
zstep = step(3);

slice_order = 1:nb_slices;

if zstep >= 0
  switch(order)
   case 'sequential ascending'
    slice_order = 1:nb_slices;
   case 'sequential descending'
    slice_order = nb_slices:-1:1;
   case 'interleaved ascending'
    if strcmp(first,'odd') 
      slice_order = [1:2:nb_slices 2:2:nb_slices];
    elseif strcmp(first,'even')
      slice_order = [2:2:nb_slices 1:2:nb_slices];
    end
   case 'interleaved descending'
    if strcmp(first,'odd')
      slice_order = [nb_slices:-2:1 nb_slices-1:-2:1];
    elseif strcmp(first,'even')
      slice_order = [nb_slices-1:-2:1 nb_slices:-2:1];
    end
  end
elseif zstep <= 0
  switch(order)
   case 'sequential ascending'
    slice_order = nb_slices:-1:1;
   case 'sequential descending'
    slice_order = 1:nb_slices;
   case 'interleaved ascending'
    if strcmp(first,'odd')
      slice_order = [nb_slices:-2:1 nb_slices-1:-2:1];
    elseif strcmp(first,'even')
      slice_order = [nb_slices-1:-2:1 nb_slices:-2:1];
    end
   case 'interleaved descending'
    if strcmp(first,'odd') 
      slice_order = [1:2:nb_slices 2:2:nb_slices];
    elseif strcmp(first,'even')
      slice_order = [2:2:nb_slices 1:2:nb_slices];
    end
  end
end