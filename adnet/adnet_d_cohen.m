%% calculate cohen's d

% effect size of difference between group per site ... also pooled?
% 4 effect sizes (1 for each site) and 1 pooled effect size PER CONNECTION

% load .mat file
d_cohen = zeros(length(list_sig),size(tab,2)); % a connection x site table
for ssite = 1:size(tab,2)
    for ss = 1:(size(list_sig,1))
     
        m_cne = mean(tab{2,1}(:,ss));   % mean connectivity of cne
        n_cne = size(tab{2,1}(:,ss),1); % number of cne
        std_cne = std(tab{2,1}(:,ss));  % std connectivity of cne
    
        m_mci = mean(tab{3,1}(:,ss));   % mean connectivity of mci
        n_nci = size(tab{3,1}(:,ss),1); % number of mci
        std_mci = std(tab{3,1}(:,ss));  % std connectivity of mci
    
        s_pool = sqrt(((n_mci-1)*std_mci^2 + (n_cne-1)*std_cne^2)/(n_mci+n_cne-2)); % pooled standard deviation
        d_cohen(ss,ssite) = (m_mci - m_cne)/s_pool;
    end
end
