%% The purpose of this script is to run a GLM on the preprocessed files of the 
% Scores pipeline using the Abide dataset. This is still an evaluation of
% the scores method and therefore belongs here and not in the Abide
% project.
clear all; close all;
%% Define the paths
scores_path = '/data1/abide/Out/Scores/sc07/time/stability_maps';
sub_list = '/data1/abide/Pheno/subjects.csv';
path_list = '/data1/abide/Pheno/paths.csv';
out_path = '/data1/abide/glm';
mask_path = '/data1/cambridge/template/template_mask.nii.gz';
glm_path = '/data1/scores/glm/abide/glm_abide.mat';
project_path = '/data1/scores/glm/abide';
scale = 7;
%% Load the things
% Load the subject list
subjects = niak_string2lines(fread(fopen(sub_list), Inf, 'uint8=>char')');
paths = niak_string2lines(fread(fopen(path_list), Inf, 'uint8=>char')');
n_subs = length(subjects);
% Load the mask
[~, mask] = niak_read_vol(mask_path);
n_voxl = sum(mask(:));
mask = repmat(mask, 1,1,1, scale);
% Load the glm model
tmp = load(glm_path, 'glm');
X = tmp.glm;
%% Now get the subjects and run (away) - if we haven't already
y_name = sprintf('abide_y_scale_%d.mat', scale);
y_path = [project_path filesep y_name];
if ~exist(y_path, 'file')
    fprintf('I need to generate %s\n', y_path);
    % Build the samples
    Y = zeros(n_subs, n_voxl, scale);
    for sid = 1:n_subs
        path = paths{sid};
        sub = subjects{sid};
        % Get the volume
        [~, vol] = niak_read_vol(path);
        % Mask the volume
        vec = vol(logical(mask));
        % Reshape that long nothing into something
        vec_res = reshape(vec, n_voxl, scale);
        % Store it in the Y
        Y(sid, :, :) = vec_res;
    end
    % Now save that gargantuan thing
    save(y_path, 'Y', '-v7.3');
else
    % It's already there, just pick it up
    fprintf('%s is already there, I am loading it\n', y_path);
    load(y_path);
end
%% Alright, we now have the model and the variables. Let's run
% Make a simple F-Test contrast that includes all covariates except the
% intercept
C = ones(20,1);
C(1) = 0;
% Now stitch it all together and run
glm.x = X;
glm.y = Y(:,:,1);
glm.c = C;
opt.test = 'ftest';
opt.flag_beta = true;
results = niak_glm(glm, opt);
