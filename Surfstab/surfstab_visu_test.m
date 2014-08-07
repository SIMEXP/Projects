function status = surfstab_visu_test(in_path, out_path)
%% Script to visualize things from the test case for the stability pipeline
in_path = niak_full_path(in_path);
close all
%% Set the general parameters

path_data = [in_path 'data.mat'];
path_ref = [in_path 'part_ref.mat'];
plugin_name = 'plugin_partition.mat';
core_name = 'stab_core.mat';
cons_name = 'consensus_partition.mat';
mstep_name = 'msteps_part.mat';
stab_name = 'surf_stab_average.mat';
sil_name = 'surf_silhouette.mat';

% Load Reference Partition
ref = load(path_ref);
part = ref.part;
dims = sqrt(length(part(:,1)));

%% External Partition Vanilla
% Set the name of the current simulation
simu_name = 'ext_vanilla';
fig_path = niak_full_path([in_path simu_name]);

% Show the reference Partition
ref_fig = figure('name', 'Reference Partition');
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);
% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% External Partition Cores
% Set the name of the current simulation
simu_name = 'ext_cores';
fig_path = niak_full_path([in_path simu_name]);

% Show the reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Stable Cores
core_path = [fig_path core_name];
show_core(core_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% External Partition Kcores Vanilla
% Set the name of the current simulation
simu_name = 'ext_kcores_vanilla';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% External Partition Kcores Cores
% Set the name of the current simulation
simu_name = 'ext_kcores_cores';
fig_path = niak_full_path([in_path simu_name]);
% Show the reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Stable Cores
core_path = [fig_path core_name];
show_core(core_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% Plugin Partition Vanilla
% Set the name of the current simulation
simu_name = 'plugin_vanilla';
fig_path = niak_full_path([in_path simu_name]);

% Show the reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Plugin
plugin_path = [fig_path plugin_name];
show_plugin(plugin_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;


%% Plugin Cores
% Set the name of the current simulation
simu_name = 'plugin_cores';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Plugin
plugin_path = [fig_path plugin_name];
show_plugin(plugin_path);
% Show Stable Cores
core_path = [fig_path core_name];
show_core(core_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% Consensus Find Vanilla
% Set the name of the current simulation
simu_name = 'cons_vanilla';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Consensus
cons_path = [fig_path cons_name];
show_cons(cons_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% Consensus Find Cores
% Set the name of the current simulation
simu_name = 'cons_cores';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show Consensus
cons_path = [fig_path cons_name];
show_cons(cons_path);
% Show Stable Cores
core_path = [fig_path core_name];
show_core(core_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% Consensus MSTEP Vanilla
% Set the name of the current simulation
simu_name = 'cons_mstep_vanilla';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show MSTEP Consensus
mstep_path = [fig_path mstep_name];
show_mstep(mstep_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;

%% Consensus MSTEP Cores
% Set the name of the current simulation
simu_name = 'cons_mstep_cores';
fig_path = niak_full_path([in_path simu_name]);
% Show Reference Partition
ref_fig = figure;
niak_visu_matrix(reshape(part(:,1), [dims dims]));
clear title;
title(sprintf('Reference Partition @ scale %d', ref.scale_tar(1)));
movegui(ref_fig, 'northwest');

% Show MSTEP Consensus
mstep_path = [fig_path mstep_name];
show_mstep(mstep_path);
% Show Silhouette
sil_path = [fig_path sil_name];
show_sil(sil_path);
% Show Show Stab of first network at first scale in scale_names
stab_path = [fig_path stab_name];
show_stab(stab_path);

% Wait for Keypress
fprintf('Waiting for Keypress...\n');
pause('on');
pause;
close all;
%% Subfunctions
    function sil_fig = show_sil(sil_path)
        % Show Silhouette
        fprintf('Loading Silhouette from %s\n', sil_path);
        sil = load(sil_path);
        sil_scale = sil.scale_names{1};
        show_sil = sil.sil_surf.(sil_scale);
        dims = sqrt(length(show_sil));
        
        fprintf('Plotting Silhouette Map\n');
        sil_fig = figure('name', 'Silhouette Figure');
        clear title;
        niak_visu_matrix(reshape(show_sil, [dims dims]));
        title(sprintf('Silhouette @ scale %s', sil_scale));
        movegui(sil_fig, 'southeast');
    end

    function stab_fig = show_stab(stab_path)
        % Show Stability
        fprintf('Loading Stability Map from %s\n', stab_path);
        stab = load(stab_path);
        stab_scale = stab.scale_names{1};
        show_stab = stab.stab.(stab_scale)(1,:);
        dims = sqrt(length(show_stab));
        
        fprintf('Plotting Stability Map\n');
        stab_fig = figure('name', 'Stability Map');
        clear title;
        niak_visu_matrix(reshape(show_stab, [dims dims]));
        title(sprintf('Stability Map of first Cluster @ scale %s', stab_scale));
        movegui(stab_fig, 'southwest');
    end

    function plug_fig = show_plugin(plugin_path)
        % Show Plugin Partition
        fprintf('Loading Plugin Partition from %s\n', plugin_path);
        plug = load(plugin_path);
        plug_scale = plug.scale_tar(1);
        show_plug = plug.part(:,1);
        dims = sqrt(length(show_plug));
        
        fprintf('Plotting Plugin Partition\n');
        plug_fig = figure('name', 'Plugin Partition');
        clear title;
        niak_visu_matrix(reshape(show_plug, [dims dims]));
        title(sprintf('Plugin Partition @ scale %d', plug_scale));
        movegui(plug_fig, 'northeast');
    end

    function cons_fig = show_cons(cons_path)
        % Show Consensus Partition
        fprintf('Loading Consensus Partition from %s\n', cons_path);
        cons = load(cons_path);
        cons_scale = cons.scale_tar(1);
        show_cons = cons.part(:,1);
        dims = sqrt(length(show_cons));
        
        fprintf('Plotting Consensus Partition\n');
        cons_fig = figure('name', 'Consensus Partition');
        clear title;
        niak_visu_matrix(reshape(show_cons, [dims dims]));
        title(sprintf('Consensus Partition @ scale %d', cons_scale));
        movegui(cons_fig, 'northeast');
    end

    function mstep_fig = show_mstep(mstep_path)
        % Show MSTEP Partition
        fprintf('Loading MSTEP Partition from %s\n', mstep_path);
        mstep = load(mstep_path);
        mstep_scale = mstep.scale_tar(1);
        show_mstep = mstep.part(:,1);
        dims = sqrt(length(show_mstep));
        
        fprintf('Plotting MSTEP Partition\n');
        mstep_fig = figure('name', 'MSTEP Partition');
        clear title;
        niak_visu_matrix(reshape(show_mstep, [dims dims]));
        title(sprintf('MSTEP Partition @ scale %d', mstep_scale));
        movegui(mstep_fig, 'northeast');
    end

    function core_fig = show_core(core_path)
        % Show Stable Cores
        fprintf('Loading Stable Cores from %s\n', core_path);
        core = load(core_path);
        core_scale = core.scale_tar(1);
        show_core = core.part(:,1);
        dims = sqrt(length(show_core));
        
        fprintf('Plotting Stable Cores\n');
        core_fig = figure('name', 'Stable Cores Partition');
        clear title;
        niak_visu_matrix(reshape(show_core, [dims dims]));
        title(sprintf('Stable Cores @ scale %d', core_scale));
        movegui(core_fig, 'north');
    end
end
