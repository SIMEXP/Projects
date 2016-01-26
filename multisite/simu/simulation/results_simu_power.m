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

%addpath(genpath('/usr/local/niak/niak-boss-0.12.13'));

clear all
lw = 3;
lwh0=1.5;
xps = {'samps_s120_15pct','samps_s120_30pct','samps_s120_50pct','samps_s80_15pct','samps_s80_30pct','samps_s80_50pct','samps_s40_15pct','samps_s40_30pct','samps_s40_50pct','samps_s33_15pct','samps_s33_30pct','samps_s33_50pct','samps_s33_25_75','samps_s33_75_25'};

for idxp = 1:size(xps,2)
	label_fig = xps{idxp};
	path_data = ['/data/cisl/cdansereau/multisite/simulations' ];
	file_data = [path_data filesep 'n_subject_estimation_bis.mat'];
	load(file_data)

	file_res = [path_data filesep label_fig filesep 'results_simu_power.mat'];
	load(file_res)
	f_handle = figure
	for i=1:10
		subplot(2,5,i),
		hold on
		conn_name=label_seed{i};
		conn_name = conn_name(5:end);
		conn_name = strrep(conn_name,'_','');
		conn_name = strrep(conn_name,'X','-');
		title(conn_name)
		plot(list_effect_size,0.001*ones(size(sens_multisite_h0(1,:,1))),'g--','linewidth',lwh0)
                plot(list_effect_size,squeeze(sens_monosite(1,:,i)),'r','linewidth',lw)
		plot(list_effect_size,squeeze(sens_multisite_nocorr(1,:,i)),'k','linewidth',lw)
		plot(list_effect_size,squeeze(sens_multisite_dummyvar(1,:,i)),'b','linewidth',lw)
		plot(list_effect_size,squeeze(sens_multisite_metal(1,:,i)),'m','linewidth',lw)
		plot(list_effect_size,squeeze(sens_multisite_h0(1,:,i)),'k--','linewidth',lwh0)
		plot(list_effect_size,squeeze(sens_multisite_h0_dummy(1,:,i)),'b--','linewidth',lwh0)
		plot(list_effect_size,squeeze(sens_multisite_h0_metal(1,:,i)),'m--','linewidth',lwh0)
		grid on
        axis square
		xlim ([min(list_effect_size), max(list_effect_size)])%axis tight
		set(gca,'xtick',[0:0.5:1.5]);
		hold off
	end
	FS = findall(f_handle,'-property','FontSize');
        set(FS,'FontSize',8);
	print(f_handle,[path_data filesep 'multisite_simulation_' label_fig '.pdf'],'-dpdf');
end

xps = {'samps_s120_rnd','samps_s80_rnd','samps_s40_rnd','samps_s33_rnd'};

for idxp = 1:size(xps,2)
        label_fig = xps{idxp};
        path_data = ['/data/cisl/cdansereau/multisite/simulations' ];
        file_data = [path_data filesep 'n_subject_estimation_bis.mat'];
        load(file_data)

        file_res = [path_data filesep label_fig filesep 'results_simu_power.mat'];
        load(file_res)
        f_handle = figure
        for i=1:10
                subplot(2,5,i),
                hold on
                conn_name=label_seed{i};
                conn_name = conn_name(5:end);
                conn_name = strrep(conn_name,'_','');
                conn_name = strrep(conn_name,'X','-');
                title(conn_name)
                plot(list_effect_size,0.001*ones(size(sens_multisite_h0(1,:,1))),'g--','linewidth',lwh0)
                plot(list_effect_size,squeeze(sens_monosite(1,:,i)),'r','linewidth',lw)
                plot(list_effect_size,squeeze(sens_multisite_nocorr(1,:,i)),'k','linewidth',lw)
                plot(list_effect_size,squeeze(sens_multisite_dummyvar(1,:,i)),'b','linewidth',lw)
                plot(list_effect_size,squeeze(sens_multisite_h0(1,:,i)),'k--','linewidth',lwh0)
                plot(list_effect_size,squeeze(sens_multisite_h0_dummy(1,:,i)),'b--','linewidth',lwh0)
		grid on
        axis square
		xlim ([min(list_effect_size), max(list_effect_size)]);%axis tight
                set(gca,'xtick',[0:0.5:1.5]);
		hold off
        end
	FS = findall(f_handle,'-property','FontSize');
	set(FS,'FontSize',8);
        print(f_handle,[path_data filesep 'multisite_simulation_' label_fig '.pdf'],'-dpdf');
end


