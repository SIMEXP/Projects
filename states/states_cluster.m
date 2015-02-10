function states = states_cluster(y,length_w)

S = length(y);
conn = cell(S,1);
for ss = 1:S
    [T,N] = size(y);
    if length_w>T
        error('The windows length length_w needs to be smaller than the number of time samples for subject %i!',ss)
    end
    nb_w = T-length_w+1;
    for ww = 1:nb_w
        R = corr(y{ss}(ww:(ww+length_w-1),:)); % Build correlation matrix on window
        R = R(tril(true(N),-1)); % extract the triangular part of the matrix
        if ww == 1
            conn{ss} = zeros(length(R),nb_w);
        end
        conn{ss}(:,ww) = 0.5 * log( (1+R)./(1-R) ); % Fisher transform the correlation values
    end
end