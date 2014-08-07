%% Make the figures, please
search_path = '/home/surchs/Project/surfstab/local/simus/one/';
data_pattern = 'simu_var_\w*.mat';
out_path = '/home/surchs/Project/surfstab/local/simus/one/figures';

param_prec = 2;

if ~isdir(out_path)
    niak_mkdir(out_path);
    warning('Created out dir at %s\n', out_path);
end

search_dir = dir(search_path)';

% Loop through the directories
for item = search_dir
    if item.isdir
        % This is a directory
        fprintf('Found directory %s\n', item.name);
        cur_path = fullfile(search_path, item.name);
        % Get the fwhm and variance from the dir name
        fwhm_match_i = regexp(item.name, '(?<=fwhm_)\d*', 'match');
        fwhm_match_d = regexp(item.name, '(?<=fwhm_\d*_)\d*', 'match');
        var_match_i = regexp(item.name, '(?<=var_)\d*', 'match');
        var_match_d = regexp(item.name, '(?<=var_\d*_)\d*', 'match');
        if ~isempty(fwhm_match_i) && ~isempty(var_match_i) && ~isempty(fwhm_match_d) && ~isempty(var_match_d)
            fwhm_i = str2double(fwhm_match_i{1});
            var_i = str2double(var_match_i{1});
            fwhm_d = str2double(fwhm_match_d{1}) / 10^param_prec;
            var_d = str2double(var_match_d{1}) / 10^param_prec;
            fwhm = fwhm_i + fwhm_d;
            var = var_i + var_d;
        else
            % The dir name does not contain fwhm and var
            warning('%s does not contain fwhm or var in its name. Skipping\n', cur_path);
            continue
        end
        
        % Search for the data file
        files = dir(cur_path)';
        data = [];
        for file = files
            match = regexp(file.name, data_pattern, 'match');
            if ~isempty(match)
                data = load([cur_path filesep file.name]);
                R = niak_build_correlation(data.data);
                hier = niak_hierarchical_clustering(R);
                order = niak_hier2order(hier);
                data_mat = R(order, order);
            end
        end
        if isempty(data)
            error('I did not find any data file at %s.\n', cur_path);
        end

        % Load Partition
        part = load([cur_path filesep 'stab_core.mat']);
        % Load Silhouette
        sil = load([cur_path filesep 'surf_silhouette.mat']);
        
        % Grab the scales
        scales = sil.scale(:);
        scale_names = sil.scale_names;
        num_scale = length(scales);
        
        if ~scales == part.scale(:)
            error('part and sil scale don''t match for %s.\n', cur_path);
        end
        
        for sc_id = 1:num_scale
            scale = scales(sc_id);
            sc_name = scale_names{sc_id};
            % Grab the correct matrices
            part_mat = reshape(part.part(:, sc_id), [16 16]);
            sil_mat = reshape(sil.sil_surf.(sc_name), [16 16]);
            stab_inter = reshape(sil.stab_surf.(sc_name).inter, [16 16]);
            stab_intra = reshape(sil.stab_surf.(sc_name).intra, [16 16]);

            % Go and make the figures
            fig = figure('visible','off');
            opt.color_map = 'jet';
            
            % Top Left
            subplot(4,2,1);
            niak_visu_matrix(part_mat, opt);
            title(sprintf('Stable Cores @ %d', scale));
            
            % Opt configured for the rest
            opt.color_map = niak_hot_cold;
            opt.limits = [-1 1];
            % Top Right
            subplot(4,2,2);
            niak_visu_matrix(sil_mat, opt);
            title('Silhouette');
            % Center
            subplot(4,2,[3,4,5,6]);
            niak_visu_matrix(data_mat, opt);
            title(sprintf('Temporal correlation f(%.2f), v(%.2f)',fwhm, var));
            % Bottom Left
            subplot(4,2,7);
            niak_visu_matrix(stab_inter, opt);
            title('Between Cluster Stability');
            % Bottom Right
            subplot(4,2,8);
            niak_visu_matrix(stab_intra, opt);
            title('Within Cluster Stability');
            
            suptitle(sprintf('Scale %d, fwhm %.2f, variance %.2f', scale, fwhm, var));
            
            % Name of the file to save
            img_name = sprintf('f_%d_%d_v_%d_%d_sc_%d.png', fwhm_i, fwhm_d, var_i, var_d*10^param_prec, scale);
            img_path = [out_path filesep img_name];
            print(fig, img_path, '-dpng');
            close(fig);
            clear opt;
            
        end
    end
end
        


        