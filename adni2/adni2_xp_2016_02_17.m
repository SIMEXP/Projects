% Objectives: identify subtypes in ADNI2 and associate the weights with pathology. 
%   Use the information about acquisition sites in the test. 
%
% Processing: Done on PB's laptop. 
%
% Results: 

clear

%% Read model
nb_subtype = 5;
path_data = [pwd filesep];
sc = '007'; % '007' '012'
file_model = [path_data 'admci_model_multi_site_scanner_fd_snr_20151117.csv'];
file_parcel = [path_data 'template_cambridge_basc_multiscale_sym_scale' sc '.mnc.gz'];
[hdr_t,parcel] = niak_read_vol(file_parcel);
[tab,list_subject,ly] = niak_read_csv(file_model);
mask = parcel>0;

%% Select subset of the model
ind_cov = [1 2 5 6 7 15 17:29];
mask_adni2 = (tab(:,9)>0);
tab = tab(mask_adni2,:);
list_subject = list_subject(mask_adni2);
tab = tab(:,ind_cov);
ly = ly(ind_cov);
mask_nnan = ~max(isnan(tab),[],2);
tab = tab(mask_nnan,:);
list_subject = list_subject(mask_nnan);

%% Read connectivity maps
mask_missing = false(length(list_subject),1);
for ssub = 1:length(list_subject)
    niak_progress(ssub,length(list_subject))
    subject = list_subject{ssub};
    file_conn = dir([path_data '*' subject '*']);
    if length(file_conn)==0
        warning('Could not find map for %s',subject);
        mask_missing(ssub) = true;
        continue
    elseif length(file_conn)>1
        warning('I found too many maps for %s. Using the first',subject);
    end
    [hdr,vol_tmp] = niak_read_vol([path_data file_conn(1).name]);
    tseries = niak_vol2tseries(vol_tmp,mask)';
    if ssub == 1
        data = zeros([length(list_subject) size(tseries)]);
    end
    data(ssub,:,:) = tseries;
end
list_subject = list_subject(~mask_missing);
data = data(~mask_missing,:,:);
tab = tab(~mask_missing,:);

%% Remove sites which do not have enough subjects
mask_sites = tab(:,7:19);
nb_subject = sum(mask_sites,1);
to_keep = max(mask_sites(:,nb_subject<10),[],2)==0;
list_subject = list_subject(to_keep);
tab = tab(to_keep,:);
ind_sites_small = find(nb_subject<10);
sites_to_keep = true(size(tab,2),1);
sites_to_keep(ind_sites_small+6) = false;
tab = tab(:,sites_to_keep);
ly = ly(sites_to_keep);
data = data(to_keep,:,:);

%%% Regress confounds
%mask_mci = tab(:,3);
%mask_ad = tab(:,4);
%mask_ctl = ~(mask_mci|mask_ad);
%
%model.x = [ones(length(list_subject),1) tab(:,1) tab(:,2) tab(:,6)];
%for nn = 1:size(data,3)
%    model.y = data(:,:,nn);
%    model.c = [1 0 0 0];
%    opt_glm.test = 'ttest';
%    opt_glm.flag_residuals = true;
%    glm = niak_glm(model,opt_glm);
%    data(:,:,nn) = glm.e;
%end
    
%% Subype 
for nn = 1:size(data,3)
    sub(nn) = adni_build_subtypes(data(:,:,nn),nb_subtype);
end

%% Test associations

%for nn = 1:size(data,3)
flag_verb = false;
tab(mask_ad>0,3) = NaN;
tab(mask_mci>0,4) = NaN;
tab(mask_ctl>0,5) = NaN;
 
for nn = [2 5 6 7]
    %model.x = [tab(:,1:2) tab(:,3) tab(:,6) tab(:,7:13)]; % MCI-CTL
    %model.x = [tab(:,1:2) tab(:,4) tab(:,6) tab(:,7:13)]; % MCI-CTL
    model.x = [tab(:,1:2) tab(:,5) tab(:,6) tab(:,7:13)]; % MCI-CTL
    mask_nan = max(isnan(model.x),[],2);
    model.x = model.x(~mask_nan,:); 
    model.y = sub(nn).weights(~mask_nan,:);
    model.c = [0 0 1 0 0 0 0 0 0 0 0];
    if ~flag_verb
        flag_verb = true;
        sum(model.x(:,3))
        sum(~model.x(:,3))
    end
    opt_glm.test = 'ttest';
    glm = niak_glm(model,opt_glm);
    glm.pce
end
figure
ss = 1;
plot(model.x(:,2)+0.2*rand(size(model.x(:,2))),model.y(:,1),'.')
