%% calculate cohen's d

% effect size of difference between group per site
% 4 effect sizes (1 for each site) PER CONNECTION

% load .mat file
d_cohen = zeros(length(list_sig),size(tab,2)); % a connection x site table with Cohen's d
std_d   = zeros(length(list_sig),size(tab,2)); % a connection x site table with standard deviation of Cohen's d

for ssite = 1:size(tab,2)
    for ss = 1:(size(list_sig,1))
     
        m1 = mean(tab{2,ssite}(:,ss));   % mean connectivity of cne
        n2 = size(tab{2,ssite}(:,ss),1); % number of cne
        s1 = std(tab{2,ssite}(:,ss));    % std connectivity of cne
    
        m2 = mean(tab{3,ssite}(:,ss));   % mean connectivity of mci
        n2 = size(tab{3,ssite}(:,ss),1); % number of mci
        s2 = std(tab{3,ssite}(:,ss));    % std connectivity of mci

        s_pool = sqrt(((n1-1)*s1^2 + (n2-1)*s2^2)/(n1+n2-2)); % pooled standard deviation
        d_cohen(ss,ssite) = (m1 - m2)/s_pool;
        std_d(ss,ssite) = ((n1+n2)/(n1*n2) + (d_cohen(ss,ssite)^2)/(2*(n1+n2-2)))*((n1+n2)/(n1+n2-2)); 
    end
end

   
