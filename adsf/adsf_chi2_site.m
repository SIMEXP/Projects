%% script to test distribution of patients across sites

clear all

model = 'adni_dartel_model_20161005_part.csv';


[tab,sub,ly] = niak_read_csv(model);
 dx = tab(:,1);
 site = tab(:,6);
 part = tab(:,2);

%% Build the contingency table

name_clus = {};
name_grp = {};

col_val = unique(dx)'; % find unique values from input column to differentiate the groups
[i, j] = find(~isnan(col_val)); % find the non-NaN values
list_mask = unique(j); % find unique values from non-NaN values
% Retain only non-NaN in data and differentiating variables
list_gg = col_val(list_mask); 


for pp = 1:max(part)
    nb_site = max(site); %
    for gg = 1:max(dx) % for each group
      for cc = 1:nb_site % for each site
        mask_sub = part(:)==pp; % build a mask to select subjects within one subtype
        site_part = site(mask_sub); % subjects within one site
        dx_part = dx(mask_sub);
        tmp_dx = dx_part == gg;
        nn = sum(tmp_dx.*(site_part==(cc))); % number of subjects for a single group that is one site
        contab(gg,cc) = nn;
        name_clus{cc} = ['site' num2str(cc)];
        name_grp{gg} = ['group' num2str(list_gg(gg))];
       end
    end

  % Write the table into a csv
  opt_ct.labels_x = name_grp;
  opt_ct.labels_y = name_clus;
  opt_ct.precision = 2;
  files_out.contab = strcat('adni_site_dx_contingency_sub', num2str(pp), '.csv');
  niak_write_csv(files_out.contab, contab, opt_ct)

  %% Chi-square test of the contigency table

  stats.chi2.expected = sum(contab,2)*sum(contab)/sum(contab(:)); % compute expected frequencies
  stats.chi2.X2 = (contab-stats.chi2.expected).^2./stats.chi2.expected; % compute chi-square statistic
  stats.chi2.X2(isnan(stats.chi2.X2)) = 0;
  stats.chi2.X2 = sum(stats.chi2.X2(:));
  stats.chi2.df = prod(size(contab)-[1 1]);
  stats.chi2.p = 1-chi2cdf(stats.chi2.X2,stats.chi2.df); % determine p value
  stats.chi2.h = double(stats.chi2.p<=0.05);

  %% Cramer's V

  [n_row n_col] = size(contab); % figure out size of contigency table
  col_sum = sum(contab); % sum of columns
  row_sum = sum(contab,2); % sum of rows
  n_sum = sum(sum(contab)); % sum of everything
  kk = min(n_row,n_col);
  stats.cramerv = sqrt(stats.chi2.X2/(n_sum*(kk-1))); % calculate cramer's v

  %% Save the model and stats
  files_out.stats = strcat('adni_site_dx_chi_sub', num2str(pp), '.mat');
  save(files_out.stats,'stats')

end