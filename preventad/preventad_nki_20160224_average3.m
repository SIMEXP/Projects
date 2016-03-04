%% Look at correspondence between demeaned subtypes defined on the admci and preventad samples
%% Save new subtype order (1 2 3 4) for each network in preventad with respect to admci 
%% Save diff maps of matched demeaned subtypes
%% icc on weights for runs 1 & 2
%% test associations, for each run, with subject (constant) and biomarkers (apoe4, beta, tau, apoecsf, hp volume)

clear all

% paths
model_pad = '/Users/pyeror/Work/transfert/PreventAD/models/preventad_model_20160222.csv';
model_nki = '/Users/pyeror/Work/transfert/PreventAD/models/nki_55plus_model_20160223.csv';
path_seed = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/admci_20160221_subtype12/';
path_pad1 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run1_7/rmap_part_stack/';
path_pad2 = '/Users/pyeror/Work/transfert/PreventAD/results/scores/preventad_run2_7/rmap_part_stack/';
path_nki = '/Users/pyeror/Work/transfert/PreventAD/results/scores/nki_55plus_7/rmap_part_stack/';
path_mask = '/Users/pyeror/Work/transfert/PreventAD/results/scores/';
path_results = '/Users/pyeror/Work/transfert/PreventAD/results/subtype/preventad_nki_20160224_average3/';

% subtyping
num_net = [2 5 6 7];
name_net = {'lim','dmn','cen','san'};
num_clus = [1 2 3 4];
name_clus = {'subt1','subt2','subt3','subt4'};
name_contrast = {'pad1_nki','pad2_nki'};

% association
num_pad_fd1 = 3;
num_pad_fd2 = 4;
num_pad_sex = 1;
num_pad_age = 2;
num_nki_fd = 3;
num_nki_sex = 2;
num_nki_age = 1;


% Create main ouptut directory
psom_mkdir(path_results)


for nn = 1:length(num_net)
    % Create ouptut directories
    path_res_net = [path_results 'net_' num2str(num_net(nn)) '_subt_' num2str(num_clus(nn)) '/'];
    psom_mkdir(path_res_net)
    
    % Load subtype admci map
    [hdr,mask] = niak_read_vol([path_mask 'mask.nii.gz']);
    file_seed = [path_seed 'net_' num2str(num_net(nn)) '/mean_clusters.nii.gz'];
    [hdr4,seed] = niak_read_vol(file_seed);
    data_seed = niak_vol2tseries(seed,mask);
    
    % Load pad & nki volumes
    file_pad1 = [path_pad1,'stack_net_' num2str(num_net(nn)) '.nii.gz'];
    [hdr,pad1] = niak_read_vol(file_pad1);
    pad1 = niak_vol2tseries(pad1,mask);
    
    file_pad2 = [path_pad2,'stack_net_' num2str(num_net(nn)) '.nii.gz'];
    [hdr,pad2] = niak_read_vol(file_pad2);
    pad2 = niak_vol2tseries(pad2,mask);
    
    file_nki = [path_nki,'stack_net_' num2str(num_net(nn)) '.nii.gz'];
    [hdr,nki] = niak_read_vol(file_nki);
    nki = niak_vol2tseries(nki,mask);
    
    for cc = 1:length(num_clus)
        data_seed_c = data_seed(num_clus(cc),:);
        
        % Weights
        weights_pad1(:,1) = corr(pad1',data_seed_c');
        weights_pad2(:,1) = corr(pad2',data_seed_c');
        weights_nki(:,1) = corr(nki',data_seed_c');
        
        for ww = 1:3
            if ww == 1
                weights = weights_pad1;
                model = model_pad;
                name = 'pad1';
            elseif ww == 2
                weights = weights_pad2;
                model = model_pad;
                name = 'pad2';
            else weights = weights_nki;
                model = model_nki;
                name = 'nki';
            end
            
            id = [];
            [~,id,~,~] = niak_read_csv(model);
            
            save([path_res_net name '_weights.mat'],'weights');
            
            opt.labels_y = {[name_net{nn} '_' name_clus{nn}]};
            opt.labels_x = id;
            path = [path_res_net name '_weights.csv'];
            opt.precision = 3;
            niak_write_csv(path,weights,opt);
        end
        
        
        % Association
        for gg = 1:length(name_contrast)
            
            [tab_a,id_a,~,~] = niak_read_csv(model_pad);
            [tab_b,id_b,~,~] = niak_read_csv(model_nki);
            fd_b = num_nki_fd;
            age_a = num_pad_age;
            age_b = num_nki_age;
            
            if gg == 1
                weights_a = weights_pad1;
                weights_b = weights_nki;
                fd_a = num_pad_fd1;
            else
                weights_a = weights_pad2;
                weights_b = weights_nki;
                fd_a = num_pad_fd2;
            end
            
            a = length(weights_a);
            b = length(weights_b);
            covar(1:a,1) = ones(a,1);
            covar(a+1:a+b,1) = zeros(b,1);
            conf_fd(1:a,1) = tab_a(:,fd_a);
            conf_fd(a+1:a+b,1) = tab_b(:,fd_b);
            conf_age(1:a,1) = tab_a(:,age_a)/12; % !!! age is not in same format between models...
            conf_age(a+1:a+b,1) = tab_b(:,age_b);
            weights_glm(1:a,1) = weights_a;
            weights_glm(a+1:a+b,1) = weights_b;
            constant(1:a+b,1) = ones(a+b,1);
            
            
            model_covar.x = [constant niak_normalize_tseries([covar conf_fd conf_age],'mean')]; % sex is not regressed out, colinear with samples...
            model_covar.y = weights_glm;
            covar = model_covar.y;
            model_covar.c = [0;1;0;0];
            opt_glm.test = 'ttest';
            opt_glm.flag_beta = true;
            res_covar = niak_glm(model_covar,opt_glm);
            
            if gg == 1
                pce1(nn,cc) = res_covar.pce;
            else pce2(nn,cc) = res_covar.pce;
            end
            
            figure
            mask = model_covar.x(:,2)==min(model_covar.x(:,2));
            plot(mask+1+0.1*randn(size(mask)),covar,'.','markersize',20)
            hold on
            boxplot(covar,mask);
            bh = boxplot(covar,mask);
            set(bh(:,1),'linewidth',0.5);
            set(bh(:,2),'linewidth',0.5);
            namefig = [path_res_net 'plot_' name_net{nn} '_' name_clus{nn} '_' name_contrast{gg} '.pdf'];
            print(namefig,'-dpdf','-r300')
            close all
        end
    end
end

% write stats

opt.labels_y = name_clus;
opt.labels_x = name_net;
opt.precision = 3;
path1 = [path_results 'pce1.csv'];
niak_write_csv(path1,pce1,opt);
path2 = [path_results 'pce2.csv'];
niak_write_csv(path2,pce2,opt);
  

