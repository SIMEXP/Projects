%%% NKI-enhanced:  GLM CONNECTOME SCRIPT - MAIN CONTRASTS 
%%% NOTE: files from each Release (1 to 5)

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.



clear all;
path_data = '/gs/project/gsf-624-aa/phildi/NKI/';
%path_out  = [ path_data 'quarantine_niak_v0.17.0/'];
path_out  = [ path_data 'quarantine_niak_issue100/'];
path_quarantine = [ path_out 'niak_issue100/'];

% add niak to path automatically (so don't need to do it before launching the program)
addpath(genpath(path_quarantine));


%%%%%%%%%%%%
%% DEFINE the NETWORK (from template)
%%%%%%%%%%%%

%% NETWORK from EXISTING TEMPLATE, and do without the use of BASC ... !
files_in.networks.aman = '/gs/project/gsf-624-aa/database2/preventad/templates/brain_parcellation_mcinet_basc_sym_77rois_21-22.mnc';
%files_in.networks.aman = [ path_data 'networks/aman_rois.mnc.gz' ];
%files_in.networks.tam322r = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_322rois.mnc.gz' ];
%files_in.networks.tam199r = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_199rois.mnc.gz' ];
%files_in.networks.tam77r = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_77rois.mnc.gz' ];
%files_in.networks.tam12c = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_12clusters.mnc.gz' ];
%files_in.networks.tam22c = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_22clusters.mnc.gz' ];
%files_in.networks.tam65c = [ path_data 'networks/brain_parcellation_mcinet_basc_sym_65clusters.mnc.gz' ];
%files_in.networks.camb12n = [ path_data 'networks/template_cambridge_basc_multiscale_sym_scale012.mnc.gz' ];
%files_in.networks.camb20n = [ path_data 'networks/template_cambridge_basc_multiscale_sym_scale020.mnc.gz' ];
%files_in.networks.camb36n = [ path_data 'networks/template_cambridge_basc_multiscale_sym_scale036.mnc.gz' ];
%files_in.networks.camb64n = [ path_data 'networks/template_cambridge_basc_multiscale_sym_scale064.mnc.gz' ];
%files_in.networks.camb122n = [ path_data 'networks/template_cambridge_basc_multiscale_sym_scale0122.mnc.gz' ];


%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol = 60;     % The max number is 120 vols. The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.55; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0.55; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.sary to properly set this threshold.

% EXCLUDE SUBJECTS
%  exclude the following because no info about age, sex, handedness, etc
%%%%% exclude(1).subjects = {'s0157580','s0116065'};
% exclude the following because no info for Handedness
%%%%% exclude(2).subjects = {'s0189418','s0152992'};
% exclude for bad QC (>50)
%%%%% exclude(3).subjects = {'s0101463','s0130716','s0144495','s0163059','s0175151'};
% exclude for no csv data, did not have rest2500...
%%%%% exclude(4).subjects = {'s0103714','s0136018','s0144495','s0128312','s0130716'};
% exclude the subjects that are NOT in the CSV data file!!! ... but we have data for them!
					% (in the CSV file this is listed as "900" in the age/sex/handedness)
%%%%% exclude(5).subjects = {'s0104892','s0105922'};
% exclude the following subjects for bad QC (18-49yrs)
%%%%% exclude(6).subjects = {'s0120538','s0120652','s0127665','s0123116','s0158726','s0106664','s0103365','s0189418','s0114139','s0105409','s0105316','s0171678'};
% exclude "young" (18 - 49) sujbects that were MAYBE with QC
%%%%% exclude(7).subjects = {'s0180093','s0192197','s0193358','s0178174','s0156263','s0169571','s0152872','s0116011','s0114326','s0187724','s0126996'};
% exclude subects with BDI >29
%%%%% exclude(8).subjects = {'s0111282','s0138497'};
% exclude subjects with Loss of consciousness from severe head injury
%%%%% exclude(9).subjects = {'s0108312','s0138558','s0192736','s0146688','s0152872','s0106780'};
% exclude the following subjects with no BMI or Vitals measures ... and NO DSM-IV diagnosis (verification) .... ie: 999
				% this can also be done with selection .... and may be preferred if items change over time
%%%%% exclude(10).subjects = {'s0115454','s0116039','s0118051','s0120557','s0126919','s0150589','s0152366','s0153114','s0155458','s0157580','s0158560','s0162251','s0187635','s0189478','s0194023','s0196651'};
% exclude for MDD (can also be done in selection ...)
%%%%% exclude(11).subjects = {'s0192736','s0124028','s0150062','s0187473','s0198130','s0119351','s0127733','s0165532','s0198051','s0105488','s0161200','s0147122','s0123245','s0125762','s0127209','s0189642','s0193222','s0171510','s0119866','s0132995','s0176211','s0138497'};
% exclude for PTSD (not already excluded by MDD)
%%%%% exclude(12).subjects = {'s0160620','s0152968','s0167827','s0130424','s0108355','s0188854','s0144314','s0102349','s0101783'};
% exclude for other ANXIETY (not already excluded by MDD / PTSD)
%%%%% exclude(13).subjects = {'s0137714','s0111693','s0132049','s0105356','s0127468','s0146865','s0143434','s0187884','s0113013','s0123173','s0139300','s0134715','s0160543','s0150880','s0188199','s0133646','s0102157','s0142513','s0158726','s0106639','s0192604','s0196445','s0194049'};
% exclude for Alheimer's ... BUT person listed as 35, and other cognitive scores good ...? so maybe misprint? (they are excluded anyway due to excessive movement)
%%%%% exclude(14).subjects = {'s0170400'};

opt_g.exclude_subject = {'s0157580','s0116065', ...
						's0189418','s0152992', ...
						's0101463','s0130716','s0144495','s0163059','s0175151', ...
						's0103714','s0136018','s0144495','s0128312','s0130716', ...
						's0104892','s0105922', ...
						's0120538','s0120652','s0127665','s0123116','s0158726','s0106664','s0103365','s0189418','s0114139','s0105409','s0105316','s0171678', ...
						's0180093','s0192197','s0193358','s0178174','s0156263','s0169571','s0152872','s0116011','s0114326','s0187724','s0126996', ...
						's0111282','s0138497', ...
						's0108312','s0138558','s0192736','s0146688','s0152872','s0106780', ...
						's0115454','s0116039','s0118051','s0120557','s0126919','s0150589','s0152366','s0153114','s0155458','s0157580','s0158560','s0162251','s0187635','s0189478','s0194023','s0196651', ...
						's0192736','s0124028','s0150062','s0187473','s0198130','s0119351','s0127733','s0165532','s0198051','s0105488','s0161200','s0147122','s0123245','s0125762','s0127209','s0189642','s0193222','s0171510','s0119866','s0132995','s0176211','s0138497', ...
						's0160620','s0152968','s0167827','s0130424','s0108355','s0188854','s0144314','s0102349','s0101783', ...
						's0137714','s0111693','s0132049','s0105356','s0127468','s0146865','s0143434','s0187884','s0113013','s0123173','s0139300','s0134715','s0160543','s0150880','s0188199','s0133646','s0102157','s0142513','s0158726','s0106639','s0192604','s0196445','s0194049', ...
						's0170400'};

% exclude the following because too young (can also select ages within GLM)
%%%  exclude(11).subjects = {'s0136018','s0128312','s0197698','s0118439','s0148071','s0118629','s0149254','s0197570','s0103872','s0109459','s0179454','s0199155','s0150716','s0161513','s0108781','s0113044','s0164093','s0124714','s0117289','s0130249','s0132088','s0161530','s0168007','s0182795','s0182324','s0165660','s0181960','s0157873','s0151580','s0168013','s0152384','s0166009','s0164385','s0144207','s0164326','s0181535','s0126369','s0121437','s0138697','s0188762','s0112347','s0179309','s0120659'};

% these subjects won't be excluded because NO DATA exists for them. they will be removed from the CSV:
	% 's0120538','s0120652','s0121498','s0141473','s0144344','s0101084','s0106664','s0110809','s0103365',''

% put all excluded subjects in one variable
%k=0;
%for cnt = 1:size(exclude,2)
%	exclude_subject(1,k+1:k+size(exclude(cnt).subjects,2)) = exclude(cnt).subjects;
%	k = k + size(exclude_subject,2);
%end
%opt_g.exclude_subject = exclude_subject;
  % OLD: opt_g.exclude_subject = {'s0157580','s0116065','s0189418','s0152992','s0101463','s0130716','s0144495','s0163059','s0175151','s0103714','s0136018','s0144495','s0128312','s0130716','s0104892','s0105922','s0120538','s0120652','s0127665','s0123116','s0158726','s0106664','s0103365','s0189418','s0114139','s0105409','s0105316','s0171678','s0180093','s0192197','s0193358','s0178174','s0156263','s0169571','s0152872','s0116011','s0114326','s0187724','s0126996'};


opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline

% to filter the session and run ... not sure how well this works (or how?)
		% review in code to be sure
opt_g.filter.session = {'sess1'};
% this is to filter so only get "rest2500"
opt_g.filter.run = {'rest2500'}; 


% Release #1
files_in.fmri = niak_grab_fmri_preprocess([path_data 'release1_niakIssue100/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

% Release #2
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'release2_niakIssue100/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

% Release #3
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'release3_niakIssue100/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

% Release #4
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'release4_niakIssue100/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);

% Release #5
files_in_tmp.fmri = niak_grab_fmri_preprocess([path_data 'release5_niakIssue100/'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = psom_merge_pipeline(files_in.fmri,files_in_tmp.fmri);


%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group
files_in.model.group = [path_data '/models/nki_2016_10_05_ALL2.csv'];

%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = '/gs/project/gsf-624-aa/abadhwar/Script_Phil_20161112'; % Where to store the results
%opt.folder_out = [path_out 'nki_glm_2016_11_11_aman']; % Where to store the results
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
%opt.type_fdr = 'family';  	% to allow region/seed-based analysis
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.



%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

% Group:
% 0: <18     (0) =>  43 subjects (-2 excluded)
% 1: 18 - 35 (1) => 118 subjects (-2 excluded)
% 2: 36 - 55 (2) => 120 subjects
% 3: 56 - 65 (3) =>  62 subjects (-1 excluded)
% 4: >65     (4) =>  62 subjects (-1 excluded)

% Combined:
% 0: <18     (0) =>  43 subjects (-2 excluded)
% 1: 18 - 35 (1) => 118 subjects (-2 excluded)
% 2: 36 - 55 (2) => 120 subjects
% 3: >55     (3) => 124 subjects (-2 excluded)

% Sex:
% Woman: 0
% Men:   1

% Handedness:
% Right: 1
% Left:  0
% None:  2

% SEE the CSV_KEY_DESCRIPTORS file for a complete list of variables included, and other important info
%%%%%%%%%%%%%%%%%%
%% EFFECTS of AGE

% Test for effect of age (across all subjects older than 18)
% control for BMI
opt.test.effect_age_bmi.group.contrast.Age   = 1;
opt.test.effect_age_bmi.group.contrast.Sex   = 0;
opt.test.effect_age_bmi.group.contrast.BMI   = 0;
opt.test.effect_age_bmi.group.contrast.FD_scrubbed = 0;
opt.test.effect_age_bmi.group.select.label = 'Age';
opt.test.effect_age_bmi.group.select.min = [17];

% Test for effect of age (across all subjects older than 18)
% do NOT control for BMI
opt.test.effect_age.group.contrast.Age  = 1;
opt.test.effect_age.group.contrast.Sex   = 0;
opt.test.effect_age.group.contrast.FD_scrubbed = 0;
opt.test.effect_age.group.select.label = 'Age';
opt.test.effect_age.group.select.min = [17];

% Test for effect of age (across all subjects older than 18)
% this test is to make sure it's working correctly, by doing same test, but selecting differently)
%opt.test.effect_age_grp.group.contrast.Age  = 1;
%opt.test.effect_age_grp.group.contrast.Sex   = 0;
%opt.test.effect_age_grp.group.contrast.FD_scrubbed = 0;
%opt.test.effect_age_grp.group.select.label = 'Group';
%opt.test.effect_age_grp.group.select.values = [1 2 3 4];

%% CONTRASTS between age groups
% Contrast the effect of age in young vs middle-aged
opt.test.effect_yng_vs_mid.group.contrast.Group  = 1;
%opt.test.effect_yng_vs_mid.group.contrast.Age  = 0;
opt.test.effect_yng_vs_mid.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_mid.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_mid.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_mid.group.select.label = 'Group';
opt.test.effect_yng_vs_mid.group.select.values = [1 2];

% Contrast the effect of age in young vs old
opt.test.effect_yng_vs_old.group.contrast.Group  = 1;
%opt.test.test.effect_yng_vs_old.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_old.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_old.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_old.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_old.group.select.label = 'Group';
opt.test.effect_yng_vs_old.group.select.values = [1 3];

% Contrast the effect of age in young vs very old
opt.test.effect_yng_vs_vryold.group.contrast.Group  = 1;
%opt.test.effect_yng_vs_vryold.group.contrast.Age  = 0;
opt.test.effect_yng_vs_vryold.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_vryold.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_vryold.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_vryold.group.select.label = 'Group';
opt.test.effect_yng_vs_vryold.group.select.values = [1 4];

% Contrast the effect of age in middle-aged vs old
opt.test.effect_mid_vs_old.group.contrast.Group  = 1;
%opt.test.effect_mid_vs_old.group.contrast.Age  = 0;
opt.test.effect_mid_vs_old.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_old.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_old.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_old.group.select.label = 'Group';
opt.test.effect_mid_vs_old.group.select.values = [2 3];

% Contrast the effect of age in middle-aged vs very old
opt.test.effect_mid_vs_vryold.group.contrast.Group  = 1;
%opt.test.effect_mid_vs_vryold.group.contrast.Age  = 0;
opt.test.effect_mid_vs_vryold.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_vryold.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_vryold.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_vryold.group.select.label = 'Group';
opt.test.effect_mid_vs_vryold.group.select.values = [2 4];

% Contrast the effect of age in old vs very-old 
opt.test.effect_old_vs_vryold.group.contrast.Group  = 1;
%opt.test.effect_old_vs_vryold.group.contrast.Age  = 0;
opt.test.effect_old_vs_vryold.group.contrast.Sex   = 0;
opt.test.effect_old_vs_vryold.group.contrast.BMI   = 0;
opt.test.effect_old_vs_vryold.group.contrast.FD_scrubbed = 0;
opt.test.effect_old_vs_vryold.group.select.label = 'Group';
opt.test.effect_old_vs_vryold.group.select.values = [3 4];


%% SAME contrasts, but COMBINING the OLD and VERY OLD in one group (>55)
% Contrast the effect of age in young vs all old combined
opt.test.effect_yng_vs_allold.group.contrast.Combined  = 1;
%opt.test.test.effect_yng_vs_allold.group.contrast.Age   = 0;
opt.test.effect_yng_vs_allold.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_allold.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_allold.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_allold.group.select.label = 'Combined';
opt.test.effect_yng_vs_allold.group.select.values = [1 3];

% Contrast the effect of age in middle-aged vs all old combined
opt.test.effect_mid_vs_allold.group.contrast.Combined  = 1;
%opt.test.effect_mid_vs_allold.group.contrast.Age  = 0;
opt.test.effect_mid_vs_allold.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_allold.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_allold.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_allold.group.select.label = 'Combined';
opt.test.effect_mid_vs_allold.group.select.values = [2 3];



% EFFECTS of SLEEP QUALITY, COGNITIVE PERFORMANCE (IQ), and AGE (interactions and separately)
% Test for effect of sleep quality on its own
opt.test.effect_sleep.group.contrast.SleepScore  = 1;
opt.test.effect_sleep.group.contrast.Age   = 0;
opt.test.effect_sleep.group.contrast.Sex   = 0;
opt.test.effect_sleep.group.contrast.BMI   = 0;
opt.test.effect_sleep.group.contrast.FD_scrubbed = 0;
opt.test.effect_sleep.group.select(1).label = 'Age';
opt.test.effect_sleep.group.select(1).min = [17];
opt.test.effect_sleep.group.select(2).label = 'SleepScore';
opt.test.effect_sleep.group.select(2).min = [-1];
opt.test.effect_sleep.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between sleep x age
opt.test.inter_slp_age.group.interaction.label = 'interactionsleepage';
opt.test.inter_slp_age.group.interaction.factor = {'SleepScore', 'Age'}; 
opt.test.inter_slp_age.group.contrast.SleepScore  = 0;
opt.test.inter_slp_age.group.contrast.Age   = 0;
opt.test.inter_slp_age.group.contrast.Sex   = 0;
opt.test.inter_slp_age.group.contrast.BMI   = 0;
opt.test.inter_slp_age.group.contrast.FD_scrubbed = 0;
opt.test.inter_slp_age.group.contrast.interactionsleepage  = 1;
opt.test.inter_slp_age.group.select(1).label = 'Age';
opt.test.inter_slp_age.group.select(1).min = [17];
opt.test.inter_slp_age.group.select(2).label = 'SleepScore';
opt.test.inter_slp_age.group.select(2).min = [-1];
opt.test.inter_slp_age.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for effect of cognitive performance on its own (WASI-II) ... percentile
opt.test.effect_iq_perc.group.contrast.FullFourPerc  = 1;
opt.test.effect_iq_perc.group.contrast.Age   = 0;
opt.test.effect_iq_perc.group.contrast.Sex   = 0;
opt.test.effect_iq_perc.group.contrast.BMI   = 0;
opt.test.effect_iq_perc.group.contrast.FD_scrubbed = 0;
opt.test.effect_iq_perc.group.select(1).label = 'Age';
opt.test.effect_iq_perc.group.select(1).min = [17];

% Test for effect of cognitive performance on its own (WASI-II) ... raw score
opt.test.effect_iq_raw.group.contrast.FullFourSum  = 1;
opt.test.effect_iq_raw.group.contrast.Age   = 0;
opt.test.effect_iq_raw.group.contrast.Sex   = 0;
opt.test.effect_iq_raw.group.contrast.BMI   = 0;
opt.test.effect_iq_raw.group.contrast.FD_scrubbed = 0;
opt.test.effect_iq_raw.group.select(1).label = 'Age';
opt.test.effect_iq_raw.group.select(1).min = [17];

% Test for interaction between iq x age
opt.test.inter_iq_age.group.interaction.label = 'interactioniqage';
opt.test.inter_iq_age.group.interaction.factor = {'FullFourPerc', 'Age'}; 
opt.test.inter_iq_age.group.contrast.FullFourPerc  = 0;
opt.test.inter_iq_age.group.contrast.Age   = 0;
opt.test.inter_iq_age.group.contrast.Sex   = 0;
opt.test.inter_iq_age.group.contrast.BMI   = 0;
opt.test.inter_iq_age.group.contrast.FD_scrubbed = 0;
opt.test.inter_iq_age.group.contrast.interactioniqage  = 1;
opt.test.inter_iq_age.group.select(1).label = 'Age';
opt.test.inter_iq_age.group.select(1).min = [17];

% Test for interaction between sleep x iq
opt.test.inter_slp_iq.group.interaction.label = 'interactionsleepiq';
opt.test.inter_slp_iq.group.interaction.factor = {'SleepScore', 'FullFourPerc'}; 
opt.test.inter_slp_iq.group.contrast.SleepScore  = 0;
opt.test.inter_slp_iq.group.contrast.FullFourPerc = 0;
opt.test.inter_slp_iq.group.contrast.Age   = 0;
opt.test.inter_slp_iq.group.contrast.Sex   = 0;
opt.test.inter_slp_iq.group.contrast.BMI   = 0;
opt.test.inter_slp_iq.group.contrast.FD_scrubbed = 0;
opt.test.inter_slp_iq.group.contrast.interactionsleepiq  = 1;
opt.test.inter_slp_iq.group.select(1).label = 'Age';
opt.test.inter_slp_iq.group.select(1).min = [17];
opt.test.inter_slp_iq.group.select(2).label = 'SleepScore';
opt.test.inter_slp_iq.group.select(2).min = [-1];
opt.test.inter_slp_iq.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2


% EFFECTS OF CONTENT
% effect of PAST scores 
opt.test.effect_past.group.contrast.Past  = 1;
opt.test.effect_past.group.contrast.Age   = 0;
opt.test.effect_past.group.contrast.Sex   = 0;
opt.test.effect_past.group.contrast.BMI   = 0;
opt.test.effect_past.group.contrast.FD_scrubbed = 0;
opt.test.effect_past.group.select(1).label = 'Age';
opt.test.effect_past.group.select(1).min = [17];
opt.test.effect_past.group.select(2).label = 'Past';
opt.test.effect_past.group.select(2).max = [900];
opt.test.effect_past.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% effect of FUTURE scores 
opt.test.effect_fut.group.contrast.Future  = 1;
opt.test.effect_fut.group.contrast.Age   = 0;
opt.test.effect_fut.group.contrast.Sex   = 0;
opt.test.effect_fut.group.contrast.BMI   = 0;
opt.test.effect_fut.group.contrast.FD_scrubbed = 0;
opt.test.effect_fut.group.select(1).label = 'Age';
opt.test.effect_fut.group.select(1).min = [17];
opt.test.effect_fut.group.select(2).label = 'Future';
opt.test.effect_fut.group.select(2).max = [900];
opt.test.effect_fut.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% effect of VAGUENESS scores 
opt.test.effect_vague.group.contrast.Vague  = 1;
opt.test.effect_vague.group.contrast.Age   = 0;
opt.test.effect_vague.group.contrast.Sex   = 0;
opt.test.effect_vague.group.contrast.BMI   = 0;
opt.test.effect_vague.group.contrast.FD_scrubbed = 0;
opt.test.effect_vague.group.select(1).label = 'Age';
opt.test.effect_vague.group.select(1).min = [17];
opt.test.effect_vague.group.select(2).label = 'Vague';
opt.test.effect_vague.group.select(2).max = [900];
opt.test.effect_vague.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x age
opt.test.inter_past_age.group.interaction.label = 'interactionpastage';
opt.test.inter_past_age.group.interaction.factor = {'Past', 'Age'}; 
opt.test.inter_past_age.group.contrast.Past  = 0;
opt.test.inter_past_age.group.contrast.Age   = 0;
opt.test.inter_past_age.group.contrast.Sex   = 0;
opt.test.inter_past_age.group.contrast.BMI   = 0;
opt.test.inter_past_age.group.contrast.FD_scrubbed = 0;
opt.test.inter_past_age.group.contrast.interactionpastage  = 1;
opt.test.inter_past_age.group.select(1).label = 'Age';
opt.test.inter_past_age.group.select(1).min = [17];
opt.test.inter_past_age.group.select(2).label = 'Past';
opt.test.inter_past_age.group.select(2).max = [900];
opt.test.inter_past_age.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x age
opt.test.inter_fut_age.group.interaction.label = 'interactionfuturage';
opt.test.inter_fut_age.group.interaction.factor = {'Future', 'Age'}; 
opt.test.inter_fut_age.group.contrast.Future  = 0;
opt.test.inter_fut_age.group.contrast.Age   = 0;
opt.test.inter_fut_age.group.contrast.Sex   = 0;
opt.test.inter_fut_age.group.contrast.BMI   = 0;
opt.test.inter_fut_age.group.contrast.FD_scrubbed = 0;
opt.test.inter_fut_age.group.contrast.interactionfuturage  = 1;
opt.test.inter_fut_age.group.select(1).label = 'Age';
opt.test.inter_fut_age.group.select(1).min = [17];
opt.test.inter_fut_age.group.select(2).label = 'Future';
opt.test.inter_fut_age.group.select(2).max = [900];
opt.test.inter_fut_age.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x age
opt.test.inter_vague_age.group.interaction.label = 'interactionvagueage';
opt.test.inter_vague_age.group.interaction.factor = {'Vague', 'Age'}; 
opt.test.inter_vague_age.group.contrast.Vague  = 0;
opt.test.inter_vague_age.group.contrast.Age   = 0;
opt.test.inter_vague_age.group.contrast.Sex   = 0;
opt.test.inter_vague_age.group.contrast.BMI   = 0;
opt.test.inter_vague_age.group.contrast.FD_scrubbed = 0;
opt.test.inter_vague_age.group.contrast.interactionvagueage  = 1;
opt.test.inter_vague_age.group.select(1).label = 'Age';
opt.test.inter_vague_age.group.select(1).min = [17];
opt.test.inter_vague_age.group.select(2).label = 'Vague';
opt.test.inter_vague_age.group.select(2).max = [900];
opt.test.inter_vague_age.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2


%% PAST THINKING
% Contrast the effect of age in young vs all old combined, but control for PAST thinking
opt.test.effect_yng_vs_allold_pst.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_allold_pst.group.contrast.Past  = 0;
opt.test.effect_yng_vs_allold_pst.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_allold_pst.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_allold_pst.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_allold_pst.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_allold_pst.group.select(1).values = [1 3];
opt.test.effect_yng_vs_allold_pst.group.select(2).label = 'Past';
opt.test.effect_yng_vs_allold_pst.group.select(2).max = [900];
opt.test.effect_yng_vs_allold_pst.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in young vs middle-aged combined, BUT control for past thinking
opt.test.effect_yng_vs_mid_pst.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_mid_pst.group.contrast.Past  = 0;
opt.test.effect_yng_vs_mid_pst.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_mid_pst.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_mid_pst.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_mid_pst.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_mid_pst.group.select(1).values = [1 2];
opt.test.effect_yng_vs_mid_pst.group.select(2).label = 'Past';
opt.test.effect_yng_vs_mid_pst.group.select(2).max = [900];
opt.test.effect_yng_vs_mid_pst.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in middle-aged vs all old combined, BUT control for PAST thinking
opt.test.effect_mid_vs_allold_pst.group.contrast.Combined  = 1;
opt.test.effect_mid_vs_allold_pst.group.contrast.Past  = 0;
opt.test.effect_mid_vs_allold_pst.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_allold_pst.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_allold_pst.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_allold_pst.group.select(1).label = 'Combined';
opt.test.effect_mid_vs_allold_pst.group.select(1).values = [2 3];
opt.test.effect_mid_vs_allold_pst.group.select(2).label = 'Past';
opt.test.effect_mid_vs_allold_pst.group.select(2).max = [900];
opt.test.effect_mid_vs_allold_pst.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x yng/old GROUPs
opt.test.inter_yngold_past.group.interaction.label = 'interactionyngoldpast';
opt.test.inter_yngold_past.group.interaction.factor = {'Past', 'Combined'}; 
opt.test.inter_yngold_past.group.contrast.Past  = 0;
opt.test.inter_yngold_past.group.contrast.Combined   = 0;
opt.test.inter_yngold_past.group.contrast.Sex   = 0;
opt.test.inter_yngold_past.group.contrast.BMI   = 0;
opt.test.inter_yngold_past.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngold_past.group.contrast.interactionyngoldpast  = 1;
opt.test.inter_yngold_past.group.select(1).label = 'Combined';
opt.test.inter_yngold_past.group.select(1).values = [1 3];
opt.test.inter_yngold_past.group.select(2).label = 'Past';
opt.test.inter_yngold_past.group.select(2).max = [900];
opt.test.inter_yngold_past.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x yng/mid GROUPs
opt.test.inter_yngmid_past.group.interaction.label = 'interactionyngmidpast';
opt.test.inter_yngmid_past.group.interaction.factor = {'Past', 'Combined'}; 
opt.test.inter_yngmid_past.group.contrast.Past  = 0;
opt.test.inter_yngmid_past.group.contrast.Combined   = 0;
opt.test.inter_yngmid_past.group.contrast.Sex   = 0;
opt.test.inter_yngmid_past.group.contrast.BMI   = 0;
opt.test.inter_yngmid_past.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngmid_past.group.contrast.interactionyngmidpast  = 1;
opt.test.inter_yngmid_past.group.select(1).label = 'Combined';
opt.test.inter_yngmid_past.group.select(1).values = [1 2];
opt.test.inter_yngmid_past.group.select(2).label = 'Past';
opt.test.inter_yngmid_past.group.select(2).max = [900];
opt.test.inter_yngmid_past.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between past x mid/old GROUPs
opt.test.inter_midold_past.group.interaction.label = 'interactionmidoldpast';
opt.test.inter_midold_past.group.interaction.factor = {'Past', 'Combined'}; 
opt.test.inter_midold_past.group.contrast.Past  = 0;
opt.test.inter_midold_past.group.contrast.Combined   = 0;
opt.test.inter_midold_past.group.contrast.Sex   = 0;
opt.test.inter_midold_past.group.contrast.BMI   = 0;
opt.test.inter_midold_past.group.contrast.FD_scrubbed = 0;
opt.test.inter_midold_past.group.contrast.interactionmidoldpast  = 1;
opt.test.inter_midold_past.group.select(1).label = 'Combined';
opt.test.inter_midold_past.group.select(1).values = [2 3];
opt.test.inter_midold_past.group.select(2).label = 'Past';
opt.test.inter_midold_past.group.select(2).max = [900];
opt.test.inter_midold_past.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2


%% FUTURE THINKING
% Contrast the effect of age in young vs all old combined, but control for FUTURE thinking
opt.test.effect_yng_vs_allold_fut.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_allold_fut.group.contrast.Future  = 0;
opt.test.effect_yng_vs_allold_fut.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_allold_fut.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_allold_fut.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_allold_fut.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_allold_fut.group.select(1).values = [1 3];
opt.test.effect_yng_vs_allold_fut.group.select(2).label = 'Future';
opt.test.effect_yng_vs_allold_fut.group.select(2).max = [900];
opt.test.effect_yng_vs_allold_fut.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in young vs middle-aged combined, BUT control for FUTURE thinking
opt.test.effect_yng_vs_mid_fut.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_mid_fut.group.contrast.Future  = 0;
opt.test.effect_yng_vs_mid_fut.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_mid_fut.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_mid_fut.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_mid_fut.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_mid_fut.group.select(1).values = [1 2];
opt.test.effect_yng_vs_mid_fut.group.select(2).label = 'Future';
opt.test.effect_yng_vs_mid_fut.group.select(2).max = [900];
opt.test.effect_yng_vs_mid_fut.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in middle-aged vs all old combined, BUT control for FUTURE thinking
opt.test.effect_mid_vs_allold_fut.group.contrast.Combined  = 1;
opt.test.effect_mid_vs_allold_fut.group.contrast.Future  = 0;
opt.test.effect_mid_vs_allold_fut.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_allold_fut.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_allold_fut.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_allold_fut.group.select(1).label = 'Combined';
opt.test.effect_mid_vs_allold_fut.group.select(1).values = [2 3];
opt.test.effect_mid_vs_allold_fut.group.select(2).label = 'Future';
opt.test.effect_mid_vs_allold_fut.group.select(2).max = [900];
opt.test.effect_mid_vs_allold_fut.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between future x yng/old GROUPs
opt.test.inter_yngold_futur.group.interaction.label = 'interactionyngoldfutur';
opt.test.inter_yngold_futur.group.interaction.factor = {'Future', 'Combined'}; 
opt.test.inter_yngold_futur.group.contrast.Future  = 0;
opt.test.inter_yngold_futur.group.contrast.Combined   = 0;
opt.test.inter_yngold_futur.group.contrast.Sex   = 0;
opt.test.inter_yngold_futur.group.contrast.BMI   = 0;
opt.test.inter_yngold_futur.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngold_futur.group.contrast.interactionyngoldfutur  = 1;
opt.test.inter_yngold_futur.group.select(1).label = 'Combined';
opt.test.inter_yngold_futur.group.select(1).values = [1 3];
opt.test.inter_yngold_futur.group.select(2).label = 'Future';
opt.test.inter_yngold_futur.group.select(2).max = [900];
opt.test.inter_yngold_futur.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between future x yng/mid GROUPs
opt.test.inter_yngmid_futur.group.interaction.label = 'interactionyngmidfutur';
opt.test.inter_yngmid_futur.group.interaction.factor = {'Future', 'Combined'}; 
opt.test.inter_yngmid_futur.group.contrast.Future  = 0;
opt.test.inter_yngmid_futur.group.contrast.Combined   = 0;
opt.test.inter_yngmid_futur.group.contrast.Sex   = 0;
opt.test.inter_yngmid_futur.group.contrast.BMI   = 0;
opt.test.inter_yngmid_futur.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngmid_futur.group.contrast.interactionyngmidfutur  = 1;
opt.test.inter_yngmid_futur.group.select(1).label = 'Combined';
opt.test.inter_yngmid_futur.group.select(1).values = [1 2];
opt.test.inter_yngmid_futur.group.select(2).label = 'Future';
opt.test.inter_yngmid_futur.group.select(2).max = [900];
opt.test.inter_yngmid_futur.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between future x mid/old GROUPs
opt.test.inter_midold_futur.group.interaction.label = 'interactionmidoldfutur';
opt.test.inter_midold_futur.group.interaction.factor = {'Future', 'Combined'}; 
opt.test.inter_midold_futur.group.contrast.Future  = 0;
opt.test.inter_midold_futur.group.contrast.Combined   = 0;
opt.test.inter_midold_futur.group.contrast.Sex   = 0;
opt.test.inter_midold_futur.group.contrast.BMI   = 0;
opt.test.inter_midold_futur.group.contrast.FD_scrubbed = 0;
opt.test.inter_midold_futur.group.contrast.interactionmidoldfutur  = 1;
opt.test.inter_midold_futur.group.select(1).label = 'Combined';
opt.test.inter_midold_futur.group.select(1).values = [2 3];
opt.test.inter_midold_futur.group.select(2).label = 'Future';
opt.test.inter_midold_futur.group.select(2).max = [900];
opt.test.inter_midold_futur.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2



%% VAGUE THINKING
% Contrast the effect of age in young vs all old combined, but control for VAGUE thinking
opt.test.effect_yng_vs_allold_vag.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_allold_vag.group.contrast.Vague  = 0;
opt.test.effect_yng_vs_allold_vag.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_allold_vag.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_allold_vag.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_allold_vag.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_allold_vag.group.select(1).values = [1 3];
opt.test.effect_yng_vs_allold_vag.group.select(2).label = 'Vague';
opt.test.effect_yng_vs_allold_vag.group.select(2).max = [900];
opt.test.effect_yng_vs_allold_vag.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in young vs middle-aged combined, BUT control for VAGUE thinking
opt.test.effect_yng_vs_mid_vag.group.contrast.Combined  = 1;
opt.test.effect_yng_vs_mid_vag.group.contrast.Vague  = 0;
opt.test.effect_yng_vs_mid_vag.group.contrast.Sex   = 0;
opt.test.effect_yng_vs_mid_vag.group.contrast.BMI   = 0;
opt.test.effect_yng_vs_mid_vag.group.contrast.FD_scrubbed = 0;
opt.test.effect_yng_vs_mid_vag.group.select(1).label = 'Combined';
opt.test.effect_yng_vs_mid_vag.group.select(1).values = [1 2];
opt.test.effect_yng_vs_mid_vag.group.select(2).label = 'Vague';
opt.test.effect_yng_vs_mid_vag.group.select(2).max = [900];
opt.test.effect_yng_vs_mid_vag.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Contrast the effect of age in middle-aged vs all old combined, BUT control for VAGUE thinking
opt.test.effect_mid_vs_allold_vag.group.contrast.Combined  = 1;
opt.test.effect_mid_vs_allold_vag.group.contrast.Vague  = 0;
opt.test.effect_mid_vs_allold_vag.group.contrast.Sex   = 0;
opt.test.effect_mid_vs_allold_vag.group.contrast.BMI   = 0;
opt.test.effect_mid_vs_allold_vag.group.contrast.FD_scrubbed = 0;
opt.test.effect_mid_vs_allold_vag.group.select(1).label = 'Combined';
opt.test.effect_mid_vs_allold_vag.group.select(1).values = [2 3];
opt.test.effect_mid_vs_allold_vag.group.select(2).label = 'Vague';
opt.test.effect_mid_vs_allold_vag.group.select(2).max = [900];
opt.test.effect_mid_vs_allold_vag.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between vague x yng/old GROUPs
opt.test.inter_yngold_vague.group.interaction.label = 'interactionyngoldvague';
opt.test.inter_yngold_vague.group.interaction.factor = {'Vague', 'Combined'}; 
opt.test.inter_yngold_vague.group.contrast.Vague  = 0;
opt.test.inter_yngold_vague.group.contrast.Combined   = 0;
opt.test.inter_yngold_vague.group.contrast.Sex   = 0;
opt.test.inter_yngold_vague.group.contrast.BMI   = 0;
opt.test.inter_yngold_vague.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngold_vague.group.contrast.interactionyngoldvague  = 1;
opt.test.inter_yngold_vague.group.select(1).label = 'Combined';
opt.test.inter_yngold_vague.group.select(1).values = [1 3];
opt.test.inter_yngold_vague.group.select(2).label = 'Vague';
opt.test.inter_yngold_vague.group.select(2).max = [900];
opt.test.inter_yngold_vague.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between vague x yng/mid GROUPs
opt.test.inter_yngmid_vague.group.interaction.label = 'interactionyngmidvague';
opt.test.inter_yngmid_vague.group.interaction.factor = {'Vague', 'Combined'}; 
opt.test.inter_yngmid_vague.group.contrast.Vague  = 0;
opt.test.inter_yngmid_vague.group.contrast.Combined   = 0;
opt.test.inter_yngmid_vague.group.contrast.Sex   = 0;
opt.test.inter_yngmid_vague.group.contrast.BMI   = 0;
opt.test.inter_yngmid_vague.group.contrast.FD_scrubbed = 0;
opt.test.inter_yngmid_vague.group.contrast.interactionyngmidvague  = 1;
opt.test.inter_yngmid_vague.group.select(1).label = 'Combined';
opt.test.inter_yngmid_vague.group.select(1).values = [1 2];
opt.test.inter_yngmid_vague.group.select(2).label = 'Vague';
opt.test.inter_yngmid_vague.group.select(2).max = [900];
opt.test.inter_yngmid_vague.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2

% Test for interaction between vague x mid/old GROUPs
opt.test.inter_midold_vague.group.interaction.label = 'interactionmidoldvague';
opt.test.inter_midold_vague.group.interaction.factor = {'Vague', 'Combined'}; 
opt.test.inter_midold_vague.group.contrast.Vague  = 0;
opt.test.inter_midold_vague.group.contrast.Combined   = 0;
opt.test.inter_midold_vague.group.contrast.Sex   = 0;
opt.test.inter_midold_vague.group.contrast.BMI   = 0;
opt.test.inter_midold_vague.group.contrast.FD_scrubbed = 0;
opt.test.inter_midold_vague.group.contrast.interactionmidoldvague  = 1;
opt.test.inter_midold_vague.group.select(1).label = 'Combined';
opt.test.inter_midold_vague.group.select(1).values = [2 3];
opt.test.inter_midold_vague.group.select(2).label = 'Vague';
opt.test.inter_midold_vague.group.select(2).max = [900];
opt.test.inter_midold_vague.group.select(2).operation = 'and';    % combine the selection criteria of entries 1&2




%%%%%%%%%%%%%%%%%%%%%%%%
%% AVERAGE CONNECTIVITY

%  Average connectivity for Young
opt.test.avg_yng.group.contrast.intercept = 1;
opt.test.avg_yng.group.contrast.Age  = 0;
opt.test.avg_yng.group.contrast.Sex   = 0;
opt.test.avg_yng.group.contrast.BMI   = 0;
opt.test.avg_yng.group.contrast.FD_scrubbed = 0;
opt.test.avg_yng.group.select.label = 'Group';
opt.test.avg_yng.group.select.values = [1];

%  Average connectivity for Middle
opt.test.avg_mid.group.contrast.intercept = 1;
opt.test.avg_mid.group.contrast.Age  = 0;
opt.test.avg_mid.group.contrast.Sex   = 0;
opt.test.avg_mid.group.contrast.BMI   = 0;
opt.test.avg_mid.group.contrast.FD_scrubbed = 0;
opt.test.avg_mid.group.select.label = 'Group';
opt.test.avg_mid.group.select.values = [2];

%  Average connectivity for Old
opt.test.avg_old.group.contrast.intercept = 1;
opt.test.avg_old.group.contrast.Age  = 0;
opt.test.avg_old.group.contrast.Sex   = 0;
opt.test.avg_old.group.contrast.BMI   = 0;
opt.test.avg_old.group.contrast.FD_scrubbed = 0;
opt.test.avg_old.group.select.label = 'Group';
opt.test.avg_old.group.select.values = [3];

%  Average connectivity for Very Old
opt.test.avg_vryold.group.contrast.intercept = 1;
opt.test.avg_vryold.group.contrast.Age  = 0;
opt.test.avg_vryold.group.contrast.Sex   = 0;
opt.test.avg_vryold.group.contrast.BMI   = 0;
opt.test.avg_vryold.group.contrast.FD_scrubbed = 0;
opt.test.avg_vryold.group.select.label = 'Group';
opt.test.avg_vryold.group.select.values = [4];

%  Average connectivity for All Old Combined
opt.test.avg_allold.group.contrast.intercept = 1;
opt.test.avg_allold.group.contrast.Age  = 0;
opt.test.avg_allold.group.contrast.Sex   = 0;
opt.test.avg_allold.group.contrast.BMI   = 0;
opt.test.avg_allold.group.contrast.FD_scrubbed = 0;
opt.test.avg_allold.group.select.label = 'Combined';
opt.test.avg_allold.group.select.values = [3];



%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=2,pmem=3700m,walltime=36:00:00';
opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt); 

