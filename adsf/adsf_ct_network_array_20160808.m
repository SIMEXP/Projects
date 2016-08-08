%% making subject x vertex x cortical thickness network 3D array

clear all

load msteps_part.mat % load the basc parcellations
load load preventad_civet_vertex_bl_20160216  % load the vertex x subject data

part = part'; 

% create masks for each  network
for ss = 1:max(part(2,:)) % iterate over networks in part (second parcellation)
    fname = strcat('net',num2str(ss));
    mask.(fname) = repmat((part(2,:) == ss),size(ct,1),1);
end

% make an empty 3d array
ct_net = zeros(222,81924,9); % 222 subjects, 81924 vertices, 9 networks

mname = fieldnames(mask);

% fill 3d array with cortical thickness values per netwok per subject
for cc = 1:max(part(2,:))
    ct_net(:,:,cc) = ct.*mask.(mname{cc});
end

save('ct_net_20160808.mat','ct_net')



