
addpath(genpath('/home/cdansereau/git/niak'));
addpath(genpath('/home/cdansereau/svn/psom'));
addpath(genpath('/home/cdansereau/svn/projects/multisite/simulation/'));

output_path = '/data/cisl/cdansereau/multisite/simulations/';
main_pipeline = struct();

n_subj = 10;
n_sites = 50;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [n_subj*ones(1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref*ones(1,n_sites)]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5*round(rand(1,n_sites)) ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_10subj_50sites_rndbal1090_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_10subj_50sites_rndbal1090_var0_site05');


n_subj = 10;
n_sites = 20;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [n_subj*ones(1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref*ones(1,n_sites)]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5*round(rand(1,n_sites)) ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_10subj_20sites_rndbal1090_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_10subj_20sites_rndbal1090_var0_site05');


n_sites = 50;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [randi([5,20],1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref*ones(1,n_sites)]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [0.5*round(rand(1,n_sites)) ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_rndsubj0520_50sites_rndbal1090_var0_site05.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_rndsubj0520_50sites_rndbal1090_var0_site05');

n_sites = 50;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [randi([2,15],1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [opt.std_ref*ones(1,n_sites)]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [randi([0,5],1,n_sites)/10 ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_rndsubj0215_50sites_rndbal1090_var0_siternd0005.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_rndsubj0215_50sites_rndbal1090_var0_siternd0005');

n_sites = 50;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [randi([2,15],1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [randi([0,20],1,n_sites)/10*opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [randi([0,5],1,n_sites)/10 ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_rndsubj0215_50sites_rndbal1090_varrnd02_siternd0005.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_rndsubj0215_50sites_rndbal1090_varrnd02_siternd0005');


n_sites = 50;
opt.std_ref     = 0.21823;                   % standard-deviation of the reference single site. Used to express site effects.
opt.sample      = [randi([1,15],1,n_sites)];                   % sample size per site
opt.balancing   = [randi([10,90],1,n_sites)/100];                 % proportion of pathological cases per site
opt.std_within  = [randi([0,20],1,n_sites)/10*opt.std_ref]; % standard deviation within site
opt.eff_ref     = [opt.std_ref*ones(1,n_sites)];      % patho effect sizes are expressed as a function of eff_ref per site
opt.site_effect = [randi([0,5],1,n_sites)/10 ];                   % The site effect (expressed as a fraction of std_ref)
opt.p_thresh    = 0.001;                     % The threshold on p-values for detection
opt.file_name   = [output_path 'simu_rndsubj0115_50sites_rndbal1090_varrnd02_siternd0005.pdf'];   % file name of the pdf to output
%multisite_mini_simulation(opt)
pipeline.sim.opt = opt;
pipeline.sim.command = 'multisite_mini_simulation_debalance(opt)'
main_pipeline = psom_merge_pipeline(main_pipeline,pipeline,'simu_rndsubj0115_50sites_rndbal1090_varrnd02_siternd0005');


opt_pipe.path_logs = [output_path filesep 'log_simu/logs_rnd'];
psom_run_pipeline(main_pipeline,opt_pipe);

%multisite_mini_simulation_debalance(opt)



