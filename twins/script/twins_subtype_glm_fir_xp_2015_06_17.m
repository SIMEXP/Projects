% Twins Movie subgoups fir
%  EXP1a: Scrubbing off - Normalisation 'fir_shape' - scale sci10_scg7_scf7
clear all

%% Parameters
path_root =  '/media/yassinebha/database2/twins_movie/twins_tmp/';
scale =  'sci10_scg7_scf7';
%scale =  'sci280_scg280_scf298';
num_scale = str2num(scale(strfind(scale,'scf')+3:end));

fir = 'fir_shape';
scrub = '_noscrub';
list_cov = { 'dominic_dep','sexe','FD' };
list_remove_pheno = { 'frames_OK','frames_scrubbed'};

%%Load phenotypes and scrubbing data
%combine pheno and scrubbing
pheno_raw = niak_read_csv_cell('~/github_repos/twins/script/models/twins/dominic_dep_group0a1_minus_group11a20_tmp2.csv');
master_cell = pheno_raw;
files_out  = niak_grab_all_preprocess([path_root 'fmri_preprocess_EXP2_test2']);
slave_cell = niak_read_csv_cell(files_out.quality_control.group_motion.scrubbing);
ly = slave_cell(1,:);
slave_cell = slave_cell(2:end,:);
slave_cell = [ly; slave_cell];
for cc = 1:length(slave_cell)-1;
    slave_cell{cc+1,1} = slave_cell{cc+1,1}(1:end-14);
end
pheno = combine_cell_tab(master_cell,slave_cell);
niak_write_csv_cell('/home/yassinebha/Desktop/pheno_test.csv',pheno)

%%cleannig data
%remove unused tab
mask_remove_pheno = ones(1,size(pheno,2));
for cc = 1: length(list_remove_pheno)
    mask_tmp = strfind(pheno(1,:),list_remove_pheno{cc});
    mask_tmp = cellfun(@isempty,mask_tmp);
    mask_remove_pheno = mask_remove_pheno & mask_tmp ;
end
pheno(:,~mask_remove_pheno)=[];
pheno(:,9)=[];%remove extra id colomn
lx = pheno(2:end,1);
ly = pheno(1,2:end)';
pheno = pheno(2:end,2:end);

%% Load data
path_read  = [path_root 'stability_fir_all_sad_blocs_EXP2_test2/stability_group/fir/'];
path_fmri  = [path_root 'fmri_preprocess_EXP2_test2/fmri/'];
list_files = dir([path_read 'fir_group_level_*']);
list_files = {list_files.name};
% discard subject if is not member of pheno list
for ff = 1:length(list_files);
    subject = list_files{ff}(17:end-4);
    ind_s = find(ismember(lx,subject));
    if isempty(ind_s)
        warning('Could not find subject %s',subject)
        list_files{ff}= [];
       % lx
    end
end 
list_files(cellfun(@isempty,list_files)) = [];
% load all fir
pheno_r = cell(length(list_files),size(pheno,2));
for ff = 1:length(list_files);
    subject = list_files{ff}(17:end-4);
    ind_s = find(ismember(lx,subject));
    pheno_r(ff,:) = pheno(ind_s,:);
    data = load([path_read list_files{ff}],scale);
    fir_all(:,:,ff) = data.(scale).fir_mean;
end
% convert all pheno from string to numeric
pheno_num = zeros(size(pheno_r));
for xx = 1:size(pheno_r,1)
    for yy = 1:size(pheno_r,2)
        if isempty(pheno_r{xx,yy})
            pheno_num(xx,yy) = NaN;
        else
            pheno_num(xx,yy) = str2num(pheno_r{xx,yy});
        end
    end
end

%% visualise the partition (optional)
path_scales =  [path_root 'stability_fir_all_sad_blocs_EXP2_test2/stability_group/' scale ];
opt.flag_zip = true;
niak_brick_mnc2nii(path_scales,[path_scales '_nii'],opt)
cd([path_scales '_nii'])
max_effect_vol(['brain_partition_consensus_group_' scale '.nii.gz'],['fdr_group_average_' scale '.mat']);
system('mricron  ~/database/white_template.nii.gz -c -0 -o max_abs_eff.nii.gz -c "5redyell" -l 0.005 -h 0.5 -z  &');
system(['mricron ~/database/white_template.nii.gz -c -0 -o ' path_scales '_nii/brain_partition_consensus_group_' scale '.nii.gz -c NIH -l 1 -h ' num2str(num_scale+1 ) ' -z &']);

%% Hierarchical clustering, subtypes and glm analysis
%list_ind = [171 260 130 51 292];
list_ind = [ 1:7];
list_color = {'r','b','g','k','p'};
for ii = 1:length(list_ind)
    % Clustering of subtypes
    figure(ii)
    clf
    fir_td = squeeze(fir_all(:,list_ind(ii),:));
    fir_td = fir_td./repmat(sqrt(sum(fir_td.^2,1)),[size(fir_td,1) 1]);
    fir_td(isnan(fir_td)) = 0;
    fir_td = fir_td - repmat(mean(fir_td,2),[1 size(fir_td,2)]);
    D = niak_build_distance (fir_td);
    hier = niak_hierarchical_clustering (-D);
    sil = niak_build_avg_silhouette(-D,hier);
    %[val,nb_clust] = max(sil(1:50));
    val = NaN;
    nb_clust = 5;
    fprintf('Twins_movie, max silhouette %1.2f at scale %i\n',val,nb_clust)
    part = niak_threshold_hierarchy (hier,struct('thresh',nb_clust));
    order = niak_hier2order (hier);
    subplot(3,1,1)
    niak_visu_matrix(D(order,order));
    title(sprintf('Twins movie scale %s cluster %i',scale,list_ind(ii)));
    subplot(3,1,2)
    niak_visu_part(part(order))
    subplot(3,1,3)
    plot(sil)
    % Show the subtypes
    figure(ii+length(list_ind))
    clf
    
    for cc = 1:nb_clust
        subplot(nb_clust,1,cc)
        if cc == 1 
        title(sprintf('Twins-Movie  scale %s cluster %i  Subtype %s ',scale,list_ind(ii),num2str(cc)));
        else
        title(sprintf('Subtype %s ',num2str(cc)));
        end 
        hold on 
        plot(mean(fir_all(:,list_ind(ii),part==cc),3),list_color{cc})
    end
    hold off
    % Build distance scores for all subtypes
    for cc = 1:nb_clust      
        avg_clust(:,cc) = mean(fir_td(:,part==cc),2);
        %weights(:,cc) = sum((fir_td-repmat(avg_clust(:,cc),[1 size(fir_td,2)])).^2);
        weights(:,cc) = corr(fir_td,avg_clust(:,cc));
    end
    
    % GLM analysis 
    list_cov = { 'dominic_dep','sexe','FD' };
    mask_covar = [];
    ind=[];
    covar = [];
    for cco = 1:length(list_cov)
        ind_cov = find(ismember(ly,list_cov{cco}));
        covar = [covar pheno_num(:,ind_cov)]; 
        mask_covar =[mask_covar ~isnan(covar(:,cco))]; 
    end
    
    [y,x]=find(mask_covar == 0);
    ind = ones(size(mask_covar),1);
    ind(unique(y)) = 0;
    model_tmp = [];
    % load model
    for ccx = 1 : length(list_cov)
        model_tmp = [model_tmp niak_normalize_tseries(covar(logical(ind),ccx),'none')];
    end    
    model_covar.x = [ones(sum(ind),1) model_tmp];
    model_covar.y = weights(logical(ind),:);
    for cco = 1:length(list_cov) 
        ind_cov = find(ismember(ly,list_cov{cco}));
        model_covar.c = zeros(1,size(model_covar.x,2))';           
        model_covar.c(cco+1) = 1;
        opt_glm.test = 'ttest';
        opt_glm.flag_beta = true;
        res_covar = niak_glm(model_covar,opt_glm);
        fprintf('Network %i, Covariate %s, pce = %s\n',list_ind(ii),ly{ind_cov},num2str(res_covar.pce));
        pce(cco,:,ii) = res_covar.pce;
    end
    % plot glm
    hold off
    for pp = 1:nb_clust
        figure(ii+pp+length(list_ind))
        clf
        plot(model_covar.x(:,2),model_covar.y(:,pp),[list_color{pp} '.'])
        title(sprintf('Twins-Movie weight/depression scale %s cluster %i, subtype %i',scale,list_ind(ii),pp));
    end
end
% FDR test
[fdr,test] = niak_fdr(pce(:),'BH',0.05);
