function status = surfstab_make_figures(in_path, mask_path, ref_4d)
%% A function to load things and show them
in_path = niak_full_path(in_path);
fig_path = [in_path 'figures'];
% See if the figure path exists
if ~psom_exist(fig_path)
    psom_mkdir(fig_path);
end
fig_path = niak_full_path(fig_path);

% Define some names to look for
plugin_name = 'plugin_partition.mat';
core_name = 'stab_core.mat';
cons_name = 'consensus_partition.mat';
mstep_name = 'msteps_part.mat';
stab_name = 'surf_stab_average.mat';
sil_name = 'surf_silhouette.mat';
% Bring them together with the in path
plugin_file = [in_path plugin_name];
core_file = [in_path core_name];
cons_file = [in_path cons_name];
mstep_file = [in_path mstep_name];
stab_file = [in_path stab_name];
sil_file  = [in_path sil_name];

%% Get the mask
[mhdr, mvol] = niak_read_vol(mask_path);
mask = logical(mvol);
% Get a reference 4D file
[fhdr, ~] = niak_read_vol(ref_4d);

%% Partitions
if exist(plugin_file, 'file')
    % We have a plugin partition
    img_path = [fig_path 'plugin_partition.nii.gz'];
    show_part(plugin_file, mask, fhdr, img_path);
elseif exist(core_file, 'file')
    % We have a stable core
    img_path = [fig_path 'stable_core_partition.nii.gz'];
    show_part(core_file, mask, fhdr, img_path);
elseif exist(mstep_file, 'file')
    % We have a mstep partition
    img_path = [fig_path 'mstep_partition.nii.gz'];
    show_part(mstep_file, mask, fhdr, img_path);
elseif exist(cons_file, 'file')
    % We have a consensus partition
    img_path = [fig_path 'consensus_partition.nii.gz'];
    show_part(cons_file, mask, fhdr, img_path);
else
    % We either have an external partition or no partition at all
    warning(['I didn''t find a partition at %s. Maybe there was an external '...
        'partition that is in a different place?'], in_path);
end

%% Maps - these should all be there
if ~exist(stab_file, 'file')
    % This shouldn't happen
    error('I could not find %s but I need it to continue.', stab_file);
else
    % All good, we have a stability map
    show_stab(stab_file, mask, fhdr, fig_path);
end

if ~exist(sil_file, 'file')
    % This shouldn't happen
    error('I could not find %s but I need it to continue.', sil_file);
else
    % All good, we have a silhouette map
    show_sil(sil_file, mask, fhdr, fig_path);
end

%% Subfunctions to create the figures for these things
    function out_path = show_part(in_path, mask, ohdr, out_path)
        % Show Partition
        fprintf('Loading Partition from %s\n', in_path);
        data = load(in_path);
        data_scale = data.scale_tar;
        % Generate a 4D output matrix
        out_vol = zeros([size(mask), length(data_scale)]);
        % Loop through the scales and generate an image per scale
        for scale_id = 1:length(data_scale)
            scale = data_scale(scale_id);
            % Get the partition that belongs to the scale
            part = data.part(:, scale_id);
            part_vol = niak_part2vol(part, mask);
            out_vol(:,:,:,scale_id) = part_vol;
        end
        ohdr.file_name = out_path;
        niak_write_vol(ohdr, out_vol);
        fprintf('Wrote to %s\n', out_path);

    end

    function out_path = show_stab(in_path, mask, ohdr, out_path)
        % Show Stability Maps
        fprintf('Loading Stability Map from %s\n', in_path);
        out_path = niak_full_path(out_path);
        data = load(in_path);
        data_scale = data.scale_rep;
        scale_names = data.scale_names;
        % Loop through the scales and generate an image per scale
        for scale_id = 1:length(data_scale)
            scale = data_scale(scale_id);
            scale_name = scale_names{scale_id};
            % Create a good name for the output file of the current scale
            img_name = sprintf('stability_map_sc_%d.nii.gz', scale);
            img_file = [out_path img_name];
            img_hdr = ohdr;
            img_hdr.file_name = img_file;
            % Generate a 4D output matrix
            out_vol = zeros([size(mask), length(scale)]);
            % Get the set of stabiliyt maps associated with the current
            % scale
            stab = data.stab.(scale_name);
            for net_id = 1:scale
                % Loop through the networks
                stab_net = stab(net_id, :);
                stab_vol = niak_part2vol(stab_net, mask);
                out_vol(:,:,:, net_id) = stab_vol;
            end
            % Save the 4D file for the current scale
            niak_write_vol(img_hdr, out_vol);
            fprintf('Wrote to %s\n', img_file);
        end
    end

    function out_path = show_sil(in_path, mask, ohdr, out_path)
        % Show Silhouette Maps
        fprintf('Loading Silhouette Map from %s\n', in_path);
        out_path = niak_full_path(out_path);
        data = load(in_path);
        data_scale = data.scale_tar;
        scale_names = data.scale_names;
        % Generate a 4D output matrix for all 3 metrics
        out_sil = zeros([size(mask), length(data_scale)]);
        out_intra = zeros([size(mask), length(data_scale)]);
        out_inter = zeros([size(mask), length(data_scale)]);
        % Loop through the scales and generate an image per scale
        for scale_id = 1:length(data_scale)
            scale = data_scale(scale_id);
            scale_name = scale_names{scale_id};
            % Get the set of stabiliyt maps associated with the current
            % scale
            sil = data.sil_surf.(scale_name);
            sil_vol = niak_part2vol(sil, mask);
            out_sil(:,:,:, scale_id) = sil_vol;
            
            stab_intra = data.stab_surf.(scale_name).intra;
            intra_vol = niak_part2vol(stab_intra, mask);
            out_intra(:,:,:, scale_id) = intra_vol;
            
            stab_inter = data.stab_surf.(scale_name).inter;
            inter_vol = niak_part2vol(stab_inter, mask);
            out_inter(:,:,:, scale_id) = inter_vol;
        end
            
        % Create a good name for the output file of the current scale
        sil_name = 'silhouette_map_sc.nii.gz';
        intra_name = 'stability_intra_map.nii.gz';
        inter_name = 'stability_inter.nii.gz';
        
        sil_file = [out_path sil_name];
        sil_hdr = ohdr;
        sil_hdr.file_name = sil_file;
        niak_write_vol(sil_hdr, out_sil);
        fprintf('Wrote to %s\n', sil_file);
        
        intra_file = [out_path intra_name];
        intra_hdr = ohdr;
        intra_hdr.file_name = intra_file;
        niak_write_vol(intra_hdr, out_intra);
        fprintf('Wrote to %s\n', intra_file);
        
        inter_file = [out_path inter_name];
        inter_hdr = ohdr;
        inter_hdr.file_name = inter_file;
        niak_write_vol(inter_hdr, out_inter);
        fprintf('Wrote to %s\n', inter_file);
    end
end
