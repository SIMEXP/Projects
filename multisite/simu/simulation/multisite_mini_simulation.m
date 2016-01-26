function multisite_mini_simulation(opt)
% simulations multisite effect
std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.

if exist('opt')
   std_ref     = opt.std_ref;                   % standard-deviation of the reference single site. Used to express site effects.
   sample      = opt.sample;                % sample size per site
   balancing   = opt.balancing;              % proportion of pathological cases per site
   std_within  = opt.std_within;      % standard deviation within site
   eff_ref     = opt.eff_ref;      % patho effect sizes are expressed as a function of eff_ref per site
   site_effect = opt.site_effect;                % The site effect (expressed as a fraction of std_ref)
   p_thresh    = opt.p_thresh;                   % The threshold on p-values for detection

else
   std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
   sample      = [50 50];                % sample size per site
   balancing   = [0.8 0.2];              % proportion of pathological cases per site
   std_within  = [std_ref std_ref];      % standard deviation within site
   eff_ref     = [2*std_ref 0.5*std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
   site_effect = [0.5 0];                % The site effect (expressed as a fraction of std_ref)
   p_thresh    = 0.001;                   % The threshold on p-values for detection
end

list_effect_size = [0:0.01:1.5];        % A list of patho effect sizes (which will be expressed as a fraction of std_within for each site)
nb_samples  = 1000;                    % Number of Monte-Carlo simulation samples 
lw = 3;                               % line width for plotting non-null simulations
lwh0=1.5;                             % line width for plotting null simulations

n_sites = size(sample,2);
ntotal = sum(sample);

sens_mono           = zeros(length(list_effect_size),1); % monosite  scenario
sens_multi          = zeros(length(list_effect_size),1); % multisite scenario -- no correction
sens_multi_dummy    = zeros(length(list_effect_size),1); % multisite scenario -- dummy variable correction
sens_multi_metal    = zeros(length(list_effect_size),1); % multisite scenario -- metal correction
sens_monosite_h0    = zeros(length(list_effect_size),1); % monosite  scenario -- null simulations
sens_multi_h0       = zeros(length(list_effect_size),1); % multisite scenario -- no correction, null simulations
sens_multi_h0_dummy = zeros(length(list_effect_size),1); % multisite scenario -- dummy variable correction, null simulations
sens_multi_h0_metal = zeros(length(list_effect_size),1); % multisite scenario -- dummy variable correction, null simulations

for num_samp = 1:nb_samples
    niak_progress(num_samp,nb_samples);
    for num_e = 1:length(list_effect_size)
        %% Simulate data
        y_mono    = []; % connectivity data - monosite scenario        
        y_h0      = []; % connectivity data - null scenario
        y         = []; % connectivity data - multisite scenario
        x         = []; % the covariates (patho)
        multisite = []; % integer variable coding for sites (1 for site 1, 2 for site 2, etc)
        for site_id = 1:n_sites
           % Simulate data at a single site -- multisite scenario
           opt_s = struct();
           opt_s.sample            = sample(site_id);          
           opt_s.balancing         = balancing(site_id);
           opt_s.std_ref           = std_ref;
           opt_s.std_site          = std_within(site_id);
           opt_s.std_patho         = eff_ref(site_id);
           opt_s.effect_size_patho = list_effect_size(num_e);
           opt_s.effect_size_site  = site_effect(site_id);           
           [y_tmp,x_tmp] = sub_get_model(opt_s);
           % Concatenate multisite models 
           y = [y ; y_tmp];
           x = [x ; x_tmp];
           % Simulate data at a single site -- null scenario
           opt_s.effect_size_patho = 0;
           [y_tmp,x_tmp] = sub_get_model(opt_s);
           % Concatenate multisite models 
           y_h0 = [y_h0 ; y_tmp];
           % Build the multisite covariate
           multisite = [multisite ;site_id*ones(sample(site_id),1)];
        end
        
        % Simulate data at a single site -- monosite scenario
        opt_s = struct();
        opt_s.sample            = sum(sample); 
        opt_s.balancing         = mean(balancing);
        opt_s.std_ref           = std_ref;
        opt_s.std_site          = mean(std_within);
        opt_s.std_patho         = mean(eff_ref);
        opt_s.effect_size_patho = list_effect_size(num_e);
        opt_s.effect_size_site  = mean(site_effect);
        [y_mono,x_mono] = sub_get_model(opt_s);        
 
        % Run GLM -- monosite scenario        
        glm   = struct();
        glm.x = [ones(size(x_mono,1),1) niak_normalize_tseries(x_mono,'mean')];
        glm.y = y_mono;
        glm.c = [zeros(1,size(glm.x,2)-1) 1]';        
        opt_glm = struct();
        opt_glm.test = 'ttest';
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_mono(num_e) = sens_mono(num_e) + test;

	% H0
	opt_s.effect_size_patho = 0;
	[y_mono_h0,x_mono_h0] = sub_get_model(opt_s);
        glm.y = y_mono_h0;
	glm.x = [ones(size(x_mono_h0,1),1) niak_normalize_tseries(x_mono_h0,'mean')];
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_monosite_h0(num_e) = sens_monosite_h0(num_e) + test;
        
        % multisite no corr
        glm   = struct();
        glm.x = [ones(size(x,1),1)  niak_normalize_tseries(x,'mean')]; % add intercept
        glm.y = y;
        glm.c = [zeros(1,size(glm.x,2)-1) 1]';
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi(num_e) = sens_multi(num_e) + test;

        % H0
        glm.y = y_h0;
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi_h0(num_e) = sens_multi_h0(num_e) + test;

        % multisite dummy var
        glm = struct();
        glm.x = [x];
        % include dummy variables
        sites_id = unique(multisite);
        for num_dum = 1:size(unique(multisite),1)-1
            glm.x = [multisite == sites_id(num_dum) glm.x];
        end
        glm.x = niak_normalize_tseries(glm.x,'mean'); %this is done in the
        glm.x = [ones(size(x,1),1)  glm.x]; % add intercept
        glm.y = y;
        glm.c = [zeros(1,size(glm.x,2)-1) 1]';
        opt_glm = struct();
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi_dummy(num_e) = sens_multi_dummy(num_e) + test;
        
        % H0
        glm.y = y_h0;
        [results, opt_glm]=niak_glm(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi_h0_dummy(num_e) = sens_multi_h0_dummy(num_e) + test;

        % multisite metal
        clear('opt_glm','glm')
        glm.x = [x];
        %glm.x = niak_normalize_tseries(glm.x,'mean'); %this is done in the
        %glm.x = [ones(size(x,1),1)  glm.x]; % add intercept
        glm.y = y;
        glm.c = [zeros(1,size(glm.x,2)-1) 1]';
        opt_glm.multisite = multisite;
        opt_glm.test = 'ttest';
        opt_glm.flag_verbose = false;
        [results, opt_glm]=niak_glm_multisite(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi_metal(num_e) = sens_multi_metal(num_e) + test;

        % H0
        glm.y = y_h0;
        [results, opt_glm]=niak_glm_multisite(glm,opt_glm);
        test = results.pce <= p_thresh;
        sens_multi_h0_metal(num_e) = sens_multi_h0_metal(num_e) + test;
    end
       
end
sens_mono           = sens_mono / nb_samples;
sens_multi          = sens_multi / nb_samples;
sens_multi_dummy    = sens_multi_dummy / nb_samples;
sens_multi_metal    = sens_multi_metal / nb_samples;
sens_monosite_h0    = sens_monosite_h0 / nb_samples;
sens_multi_h0       = sens_multi_h0 / nb_samples;
sens_multi_h0_dummy = sens_multi_h0_dummy / nb_samples;
sens_multi_h0_metal = sens_multi_h0_metal / nb_samples;

f_handle = figure
hold on
plot(list_effect_size,sens_mono,'r','linewidth',lw)
plot(list_effect_size,sens_multi,'k','linewidth',lw)
plot(list_effect_size,sens_multi_dummy,'b','linewidth',lw)
plot(list_effect_size,sens_multi_metal,'m','linewidth',lw)
plot(list_effect_size,mean(sens_multi_h0)*ones(size(sens_multi_h0)),'k--','linewidth',lwh0)
plot(list_effect_size,mean(sens_multi_h0_dummy)*ones(size(sens_multi_h0_dummy)),'b--','linewidth',lwh0)
plot(list_effect_size,mean(sens_multi_h0_metal)*ones(size(sens_multi_h0_metal)),'m--','linewidth',lwh0)
plot(list_effect_size,p_thresh*ones(size(sens_multi_h0_metal)),'g--','linewidth',lwh0)
grid on
legend({'monosite','multi nocorr','multi dummy','multi metal','multi h0 nocorr', 'multi h0 dummy', 'mutli h0 metal','expected p'})
%axis square
xlim ([min(list_effect_size), max(list_effect_size)])%axis tight
set(gca,'xtick',[0:0.5:1.5]);
hold off
FS = findall(f_handle,'-property','FontSize');
set(FS,'FontSize',8);

if exist('opt')
   % print the PDF
   print(f_handle, opt.file_name,'-dpdf')
   [DIR, NAME, EXT, VER] = fileparts(opt.file_name);
   file_mat = [DIR '/' NAME '.mat']
   save(file_mat,'opt','sens_mono','sens_multi','sens_multi_dummy','sens_multi_metal','sens_monosite_h0','sens_multi_h0','sens_multi_h0_dummy','sens_multi_h0_metal');
%   close(f_handle)
end

end


function [y,x_patho]=sub_get_model(opt)

   % noise
   e = randn(opt.sample,1)*opt.std_site; 
   % patho effect   
   x_patho = zeros(opt.sample,1);
   idx_patho = round(opt.balancing*opt.sample);
   eff_patho =  opt.effect_size_patho * opt.std_patho;
   x_patho(1:idx_patho) = 1;
   % site effect
   site = opt.effect_size_site * opt.std_site;
   y = eff_patho*x_patho + site + e;

end
