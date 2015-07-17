%% calculate cohen's d

% effect size of difference between group per site
% 4 effect sizes (1 for each site) PER CONNECTION

% load .mat file
cd = zeros(length(list_sig),size(tab,2)); % a connection x site table with Cohen's d
wd   = zeros(length(list_sig),size(tab,2)); % a connection x site table with the inverse of the variance of Cohen's d

for ssite = 1:size(tab,2)
    for ss = 1:(size(list_sig,1))
     
        m1 = mean(tab{2,ssite}(:,ss));   % mean connectivity of cne
        n1 = size(tab{2,ssite}(:,ss),1); % number of cne
        s1 = std(tab{2,ssite}(:,ss));    % std connectivity of cne
    
        m2 = mean(tab{3,ssite}(:,ss));   % mean connectivity of mci
        n2 = size(tab{3,ssite}(:,ss),1); % number of mci
        s2 = std(tab{3,ssite}(:,ss));    % std connectivity of mci

        s_pool = sqrt(((n1-1)*s1^2 + (n2-1)*s2^2)/(n1+n2-2)); % pooled standard deviation
        cd(ss,ssite) = (m1 - m2)/s_pool;
        wd(ss,ssite) = (((n1+n2)/(n1*n2) + (cd(ss,ssite)^2)/(2*(n1+n2-2)))*((n1+n2)/(n1+n2-2)))^(-1); 
    end
end

%% now compute pooled effect size
eff_size = zeros(length(list_sig),1); % a connection x 1 vector of pooled d estimates
for ss = 1:(size(list_sig,1))
   b = cd(ss,:);
   w = wd(ss,:);
   eff_size(ss) = sum(b.*w)/sum(w);
end