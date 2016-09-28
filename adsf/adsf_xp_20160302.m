clear

load preventad_civet_vertex_bl_20160202.mat
load msteps_part.mat

sub = niak_build_subtypes(ct,5,part(:,2)==11); % get 5 subtypes out of cortical thickness (vertex-based) using a mask for network #11 (language-ish network)