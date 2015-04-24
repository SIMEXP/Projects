clear all; close all;
edge = 64;
n_edge = edge/4;

[rr cc] = meshgrid(1:edge);
%C = sqrt((rr-16).^2+(cc-16).^2)<=10;
x = 16;
y = 16;
left_ear = sqrt((rr-n_edge).^2+(cc-n_edge).^2)<=n_edge;
right_ear = sqrt((rr-n_edge*3).^2+(cc-n_edge).^2)<=n_edge;
face = sqrt((rr-n_edge*2).^2+(cc-n_edge*2.5).^2)<=n_edge*1.4;
left_eye = sqrt((rr-n_edge*1.5).^2+(cc-n_edge*2).^2)<=n_edge/2.5;
right_eye = sqrt((rr-n_edge*2.5).^2+(cc-n_edge*2).^2)<=n_edge/2.5;
mouth = zeros(edge,edge);
mouth(n_edge*3:n_edge*3+n_edge/4,n_edge*1.5:n_edge*2.5) = 1;
mousy = logical(left_ear + right_ear + face) - left_eye - right_eye - mouth;
%C = logical(C);
mouse_mask = logical(mousy);