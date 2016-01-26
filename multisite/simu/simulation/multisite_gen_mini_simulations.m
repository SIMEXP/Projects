%addpath(genpath('/usr/local/niak/niak-boss-0.12.13'));
addpath(genpath('/home/cdansereau/git/niak'));
addpath(genpath('/home/cdansereau/svn/psom'));
addpath(genpath('/home/cdansereau/svn/projects/multisite/simulation/'));

output_path = '/data/cisl/cdansereau/multisite/simulations/';
main_pipeline = struct();

% simulation with no site effect in the patho population
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal5050_var0_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal5050_var0_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal5050_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal5050_var0_site05');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal7030_var0_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal7030_var0_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal7030_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal7030_var0_site05');

% simulation with site effect in the patho population
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal5050_var2_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal5050_var2_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal5050_var2_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal5050_var2_site05');


opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal7030_var2_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal7030_var2_site0');


opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [50 50];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_bal7030_var2_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_bal7030_var2_site05');

% simulation with site effect in the patho population site size variante
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal5050_var0_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal5050_var0_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal5050_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal5050_var0_site05');

% simulation with site effect in the patho population site size variante
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal5050_var2_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal5050_var2_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.5 0.5];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal5050_var2_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal5050_var2_site05');

% simulation with site effect in the patho population site size variante
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal7030_var0_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal7030_var0_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal7030_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal7030_var0_site05');


opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal7030_var2_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal7030_var2_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [20 80];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_2080bal7030_var2_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_2080bal7030_var2_site05');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [80 20];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_8020bal7030_var0_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_8020bal7030_var0_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [80 20];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_8020bal7030_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_8020bal7030_var0_site05');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [80 20];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_8020bal7030_var2_site0.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_8020bal7030_var2_site0');

opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [80 20];                   % sample size per site
opt.balancing   = [0.7 0.3];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref opt.std_ref]; % standard deviation within site
opt.eff_ref     = [2*opt.std_ref 0.5*opt.std_ref];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5 0];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_8020bal7030_var2_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_8020bal7030_var2_site05');

opt_pipe.path_logs = [output_path filesep 'log_simu/logs'];
psom_run_pipeline(main_pipeline,opt_pipe);

