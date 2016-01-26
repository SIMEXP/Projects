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

file_res = [path_data filesep 'results_simu_power_1000samp_25pct.mat'];
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
plot(list_effect_size,squeeze(sens_monosite_h0(3,:,i)),'c')
hold off
end
print(f_handle,[path_data filesep 'multisite_simulation_25pct.pdf'],'-dpdf');

file_res = [path_data filesep 'results_simu_power_1000samp_50pct.mat'];
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
print(f_handle,[path_data filesep 'multisite_simulation_50pct.pdf'],'-dpdf');

file_res = [path_data filesep 'results_simu_power_1000samp_75pct.mat'];
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
plot(list_effect_size,squeeze(sens_monosite_h0(3,:,i)),'c')
hold off
end
print(f_handle,[path_data filesep 'multisite_simulation_75pct.pdf'],'-dpdf');

%f_handle = figure
%hold on
%grid on
%title(['Multisite ' label_fig ' p10-3 sites (' int2str(size(label_subject,1)) 'subj)'])
%plot(list_effect_size,squeeze(sens(1,:,:)));
%print(f_handle,[path_data filesep 'multisite_' label_fig '_p10-3_' int2str(size(label_subject,1)) 'subj.pdf'],'-dpdf');

%f_handle = figure
%hold on
%grid on
%title(['Multisite ' label_fig ' p10-2 sites (' int2str(size(label_subject,1)) 'subj)'])
%plot(list_effect_size,squeeze(sens(2,:,:)));
%print(f_handle,[path_data filesep 'multisite_' label_fig '_p10-2_' int2str(size(label_subject,1)) 'subj.pdf'],'-dpdf');

%f_handle = figure
%hold on
%grid on
%title(['Multisite ' label_fig ' p5x10-2 sites (' int2str(size(label_subject,1)) 'subj)'])
%plot(list_effect_size,squeeze(sens(3,:,:)));
%print(f_handle,[path_data filesep 'multisite_' label_fig '_p5x10-2_' int2str(size(label_subject,1)) 'subj.pdf'],'-dpdf');

% f_handle = figure
% hold on
% grid on
% title('Fake Multisite 1 site (198subj)')
% plot(list_effect_size,squeeze(sens_fake(1,:,[1 2 5])),{'r-','r--','r-.'});
% plot(list_effect_size,squeeze(sens_fake(2,:,[1 2 5])),{'b-','b--','b-.'});
% plot(list_effect_size,squeeze(sens_fake(3,:,[1 2 5])),{'g-','g--','g-.'});
% print(f_handle,[path_data filesep 'multisite_fake_1site_198subj.pdf'],'-dpdf');


% f_handle = figure
% hold on
% grid on
% title('Population size impact')
% plot(list_effect_size,squeeze(sampsize(1,:)),{'r-'});
% plot(list_effect_size,squeeze(sampsize(2,:)),{'b-'});
% plot(list_effect_size,squeeze(sampsize(3,:)),{'g-'});
% print(f_handle,[path_data filesep 'multisite_nsubjects.pdf'],'-dpdf');



%f_handle = figure
%hold on
%grid on
%title('Detection power Multisite seed 1')
%plot(list_effect_size,squeeze(sens_monosite(3,:,1)),'r');
%plot(list_effect_size,squeeze(sens_multisite_nocorr(3,:,1)),'b');
%plot(list_effect_size,squeeze(sens_multisite_dummyvar(3,:,1)),'g');
%plot(list_effect_size,squeeze(sens_multisite_metal(3,:,1)),'y');
%print(f_handle,[path_data filesep 'multisite_simulation_seed1.pdf'],'-dpdf');


