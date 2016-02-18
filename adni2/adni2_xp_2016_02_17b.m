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
sc = '012'; % '007' '012'
file_model = [path_data 'admci_model_multi_site_scanner_fd_snr_20151117.csv'];
file_parcel = [path_data 'template_cambridge_basc_multiscale_sym_scale' sc '.mnc.gz'];
[hdr_t,parcel] = niak_read_vol(file_parcel);
[tab,list_subject,ly] = niak_read_csv(file_model);
mask = parcel>0;

%% Select subset of the model
ind_site = tab(:,8);
ind_cov = [1 2 5 6 7 15];
mask_adni2 = (tab(:,9)>0);
ind_site = ind_site(mask_adni2);
tab = tab(mask_adni2,:);
list_subject = list_subject(mask_adni2);
tab = tab(:,ind_cov);
ly = ly(ind_cov);
mask_nnan = ~max(isnan(tab),[],2)&~isnan(ind_site);
tab = tab(mask_nnan,:);
list_subject = list_subject(mask_nnan);
ind_site = ind_site(mask_nnan);

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
ind_site = ind_site(~mask_missing);

%% Subype 
for nn = 1:size(data,3)
    sub(nn) = adni_build_subtypes(data(:,:,nn),nb_subtype);
end

%% Test associations

%for nn = 1:size(data,3)
flag_verb = false;
type_test = 'mci_m_ctl'; % 'mci_m_ctl', 'ad_m_ctl', 'ad_m_mci'
mask_mci = tab(:,3)>0;
mask_ad = tab(:,4)>0;
mask_ctl = ~(mask_mci|mask_ad);
[val,tmp,ind_site] = unique(ind_site);
site5 = ind_site == 5;
site1 = ind_site == 1;
mask_ok = site1|site5;
%mask_ok = ~site4;
for nn = 1:12
%for nn = [2 5 6 7]
    switch type_test
        case 'all_m_ctl'
            mask_a = mask_ok;
            diff_grp = mask_mci(mask_a)|mask_ad(mask_a);
        case 'mci_m_ctl'
            mask_a = (mask_mci|mask_ctl)&mask_ok;
            diff_grp = tab(mask_a,3);
        case 'ad_m_ctl'
            mask_a = (mask_ad|mask_ctl)&mask_ok;
            diff_grp = tab(mask_a,4);
        case 'ad_m_mci'
            mask_a = (mask_ad|mask_mci)&mask_ok;
            diff_grp = tab(mask_a,5);
    end
    %model.x = [ones(sum(mask_a),1) tab(mask_a,1:2) diff_grp tab(mask_a,6)];
    model.x = [ones(sum(mask_a),1) diff_grp ];
    model.y = sub(nn).weights(mask_a,:);
%    model.y = zeros(sum(mask_a),nb_subtype);
%    for ss = 1:nb_subtype
%        model.y(:,ss) = sub(nn).part(mask_a)==ss;
%    end
    %model.c = [0 0 0 1 0];
    model.c = [0 1];
    if ~flag_verb
        flag_verb = true;
        sum(diff_grp)
        sum(~diff_grp)
    end
    [valtmp,tmp,opt_glm.multisite] = unique(ind_site(mask_a));
    opt_glm.flag_verbose = false;
    glm = niak_glm_multisite(model,opt_glm);
    glm.pce
end
figure
plot(model.x(:,2)+0.2*rand(size(model.x(:,2))),model.y(:,2),'.')

pred = model.y(:,4)>0;
val = model.x(:,2);
sum(pred==val)/length(pred)