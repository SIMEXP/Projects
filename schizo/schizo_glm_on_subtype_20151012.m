clear all
addpath(genpath('/gs/project/gsf-624-aa/quarantaine/niak-boss-0.13.3/'))


% %%%%%%%%%%%%
% %% Grabbing the results from BASC
% %%%%%%%%%%%%
% opt_g_basc.level = 'group';
% opt_g_basc.flag_tseries = false;
% files_in = niak_grab_stability_rest('/home/porban/database/zipra/zipra_basc_20140818',opt_g_basc);

files_in.networks.scale007 = '/gs/project/gsf-624-aa/database2/schizo/template_sym/template_cambridge_basc_multiscale_sym_scale007.mnc.gz';

%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = '/gs/project/gsf-624-aa/database2/schizo/models/cobre_112_subtype_model_group_20151011.csv';
[tab,sub_id,label_y,label_id] = niak_read_csv(files_in.model.group);

%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%

for n = 1:length(sub_id)
    files_in.fmri.(sub_id{n}).session1.run1 = ['/gs/project/gsf-624-aa/database2/schizo/fmri_preproc/fmri/fmri_' sub_id{n} '_session1_run1.mnc.gz'];
end


%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = '/gs/project/gsf-624-aa/database2/schizo/results/glm/schizo_glm_on_subtype_20151012'; % Where to store the results
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
%opt.type_fd1r = 'uncorrected';
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 10; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 2; % The permutation tests are separated into NB_BATCH
% independent batches, which can run on parallel if sufficient computational resources are available

opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

opt.test.all.group.contrast.intercept = 1;
opt.test.all.group.contrast.age = 0;
opt.test.all.group.contrast.sex = 0;
opt.test.all.group.contrast.fd1 = 0;

opt.test.subtype1.group.select.label = 'subtype';
opt.test.subtype1.group.select.values = 1;
opt.test.subtype1.group.contrast.intercept = 1;
opt.test.subtype1.group.contrast.age = 0;
opt.test.subtype1.group.contrast.sex = 0;
opt.test.subtype1.group.contrast.fd1 = 0;


opt.test.subtype2.group.select.label = 'subtype';
opt.test.subtype2.group.select.values = 2;
opt.test.subtype2.group.contrast.intercept = 1;
opt.test.subtype2.group.contrast.age = 0;
opt.test.subtype2.group.contrast.sex = 0;
opt.test.subtype2.group.contrast.fd1 = 0;


opt.test.subtype3.group.select.label = 'subtype';
opt.test.subtype3.group.select.values = 3;
opt.test.subtype3.group.contrast.intercept = 1;
opt.test.subtype3.group.contrast.age = 0;
opt.test.subtype3.group.contrast.sex = 0;
opt.test.subtype3.group.contrast.fd1 = 0;


opt.test.subtype4.group.select.label = 'subtype';
opt.test.subtype4.group.select.values = 4;
opt.test.subtype4.group.contrast.intercept = 1;
opt.test.subtype4.group.contrast.age = 0;
opt.test.subtype4.group.contrast.sex = 0;
opt.test.subtype4.group.contrast.fd1 = 0;


opt.test.subtype5.group.select.label = 'subtype';
opt.test.subtype5.group.select.values = 5;
opt.test.subtype5.group.contrast.intercept = 1;
opt.test.subtype5.group.contrast.age = 0;
opt.test.subtype5.group.contrast.sex = 0;
opt.test.subtype5.group.contrast.fd1 = 0;


opt.test.subtype6.group.select.label = 'subtype';
opt.test.subtype6.group.select.values = 6;
opt.test.subtype6.group.contrast.intercept = 1;
opt.test.subtype6.group.contrast.age = 0;
opt.test.subtype6.group.contrast.sex = 0;
opt.test.subtype6.group.contrast.fd1 = 0;


opt.test.subtype7.group.select.label = 'subtype';
opt.test.subtype7.group.select.values = 7;
opt.test.subtype7.group.contrast.intercept = 1;
opt.test.subtype7.group.contrast.age = 0;
opt.test.subtype7.group.contrast.sex = 0;
opt.test.subtype7.group.contrast.fd1 = 0;



%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
%opt.psom.max_queued = 24; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

