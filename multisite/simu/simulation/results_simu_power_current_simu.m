% clear
% path_data = '/home/pbellec/database/roche_multisite/simu_power';
% file_res = [path_data filesep 'results_simu_power.mat'];
% file_data = [path_data filesep 'n_subject_estimation_bis.mat'];
% load(file_res)
% load(file_data)
% 
% figure
% hold on
% plot(list_effect_size,squeeze(sens(1,:,[1 2 5])),{'r-','r--','r-.'});
% plot(list_effect_size,squeeze(sens(2,:,[1 2 5])),{'b-','b--','b-.'});
% plot(list_effect_size,squeeze(sens(3,:,[1 2 5])),{'g-','g--','g-.'});

addpath(genpath('/usr/local/niak/niak-boss-0.12.13'));


clear all
label_fig = '05scrubb';
path_data = '/data/cisl/cdansereau/multisite/simulations/';
%file_res = [path_data filesep 'results_simu_power.mat'];
file_data = [path_data filesep 'n_subject_estimation_bis.mat'];
%load(file_res)
load(file_data)

file_res = [path_data filesep 'results_simu_power.mat'];
load(file_res)
f_handle = figure
for i=1:6
subplot(2,3,i),
hold on
%title('')
plot(list_effect_size,squeeze(sens_monosite(3,:,i)),'r')
plot(list_effect_size,squeeze(sens_multisite_nocorr(3,:,i)),'b')
plot(list_effect_size,squeeze(sens_multisite_dummyvar(3,:,i)),'g')
plot(list_effect_size,squeeze(sens_multisite_metal(3,:,i)),'k')
plot(list_effect_size,squeeze(sens_multisite_h0(3,:,i)),'c')
hold off
end
print(f_handle,[path_data filesep 'multisite_simulation.pdf'],'-dpdf');

