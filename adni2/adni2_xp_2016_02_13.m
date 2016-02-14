clear

%% Read model
path_data = [pwd filesep];
sc = '007'; % '007' '012'
file_model = [path_data 'model_adni_20160121.csv'];
file_parcel = [path_data 'template_cambridge_basc_multiscale_sym_scale' sc '.mnc.gz'];
[hdr_t,parcel] = niak_read_vol(file_parcel);
[tab,list_subject,ly] = niak_read_csv(file_model);
mask = parcel>0;

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

%% Regress confounds
model.x = [ones(length(list_subject),1) tab(:,7) tab(:,1) tab(:,2)];
mask_nnan = ~max(isnan(model.x),[],2);
model.x = model.x(mask_nnan,:); 
data = data(mask_nnan,:,:);
tab = tab(mask_nnan,:);
list_subject = list_subject(mask_nnan);

for nn = 1:size(data,3)
    model.y = data(:,:,nn);
    model.c = [1 0 0 0];
    opt_glm.test = 'ttest';
    opt_glm.flag_residuals = true;
    glm = niak_glm(model,opt_glm);
    data(:,:,nn) = glm.e;
end
    
%% Subype 
for nn = 1:size(data,3)
    nb_subtype = 7;
    sub(nn) = adni_build_subtypes(data(:,:,nn),nb_subtype);
end

%% Test associations

%for nn = 1:size(data,3)
flag_verb = false;
for nn = [2 5 6 7]
    %model.x = [ones(size(sub(nn).weights,1),1) tab(:,3)>=2 tab(:,7) tab(:,1) tab(:,2)];                       % (MCI|AD)-CTL
    model.x = [ones(size(sub(nn).weights,1),1) tab(:,4) tab(:,7) tab(:,1) tab(:,2)]; % MCI-CTL
    %model.x = [ones(size(sub(nn).weights,1),1) tab(:,5) tab(:,7) tab(:,1) tab(:,2)]; % AD-CTL
    %model.x = [ones(size(sub(nn).weights,1),1) tab(:,6) tab(:,7) tab(:,1) tab(:,2)]; % AD-MCI
    mask_nan = max(isnan(model.x),[],2);
    model.x = model.x(~mask_nan,:); 
    model.y = sub(nn).weights(~mask_nan,:);
    model.c = [0 1 0 0 0];
    if ~flag_verb
        flag_verb = true;
        sum(model.x(:,2))
        sum(~model.x(:,2))
    end
    opt_glm.test = 'ttest';
    glm = niak_glm(model,opt_glm);
    glm.pce
end
figure
ss = 1;
plot(model.x(:,2)+0.2*rand(size(model.x(:,2))),model.y(:,1),'.')
