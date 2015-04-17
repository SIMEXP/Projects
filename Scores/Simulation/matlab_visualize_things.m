clear all; close all;
shifts = 0:9;
edge = 64;
names = {'scores', 'seed', 'dual regression'};
load('tpr_octave.mat');
%% Make the figure
cc=jet(n_shifts);

% Border
f1 = figure('position',[0 0 1200 600]);
for m_id = 1:3
    labels = cell(n_shifts,1);
    subplot(1,3,m_id);
    hold on;
    auc_vec = zeros(n_shifts, 1);
    for s_id = 1:n_shifts
        plot(ref_x, tpr_store(s_id, :,m_id, 1), 'color', cc(s_id,:));
        auc_vec(s_id) = trapz(ref_x,tpr_store(s_id,:,m_id, 1));
        labels{s_id} = sprintf('%.1f %% (%.2f)', (shifts(s_id)'*100)/n_edge, auc_vec(s_id));
    end
    labels{end+1} = 'chance';
    plot(ref_x, ref_x, 'k');
    title(names{m_id});
    legend(labels, 'Location', 'southeast');
    hold off;
end
legend(labels, 'Location', 'southeast');
set(f1,'PaperPositionMode','auto');
print(f1, 'roc_curves_noisy_border.png', '-dpng');

% Corner
f2 = figure('position',[0 0 1200 600]);
for m_id = 1:3
    labels = cell(n_shifts,1);
    subplot(1,3,m_id);
    hold on;
    auc_vec = zeros(n_shifts, 1);
    for s_id = 1:n_shifts
        plot(ref_x, tpr_store(s_id, :,m_id, 2), 'color', cc(s_id,:));
        auc_vec(s_id) = trapz(ref_x,tpr_store(s_id,:,m_id, 2));
        labels{s_id} = sprintf('%.1f %% (%.2f)', (shifts(s_id)'*100)/n_edge, auc_vec(s_id));
    end
    labels{end+1} = 'chance';
    plot(ref_x, ref_x, 'k');
    title(names{m_id});
    legend(labels, 'Location', 'southeast');
    hold off;
end
legend(labels, 'Location', 'southeast');
set(f2,'PaperPositionMode','auto');
print(f2, 'roc_curves_noisy_corner.png', '-dpng');

%%
% Border
f3 = figure('position',[0 0 1200 3000]);
count = 1;
for s_id = 1:n_shifts
  for m_id = 1:3
    opt.limits = [-1 1];
    subplot(n_shifts, 3, count);
    count = count + 1;
    range = max(abs(map_store(s_id, :, m_id, 1)));
    imagesc(reshape(map_store(s_id, :, m_id, 1), [edge edge]), [-range range]);
    colormap(niak_hot_cold)
    colorbar;
    grid on;
    title(sprintf('%s %.2f%%', names{m_id}, (shifts(s_id)*100)/n_edge));
  end
end
legend(labels, 'Location', 'southeast');
set(f3,'PaperPositionMode','auto');
print(f3, 'maps_permuation_roc_border.png', '-dpng');

% Corner
f4 = figure('position',[0 0 1200 3000]);
count = 1;
for s_id = 1:n_shifts
  for m_id = 1:3
    opt.limits = [-1 1];
    subplot(n_shifts, 3, count);
    count = count + 1;
    range = max(abs(map_store(s_id, :, m_id, 2)));
    imagesc(reshape(map_store(s_id, :, m_id, 2), [edge edge]), [-range range]);
    colormap(niak_hot_cold)
    colorbar;
    grid on;
    title(sprintf('%s %.2f%%', names{m_id}, (shifts(s_id)*100)/n_edge));
  end
end
legend(labels, 'Location', 'southeast');
set(f4,'PaperPositionMode','auto');
print(f4, 'maps_permuation_roc_corner.png', '-dpng');