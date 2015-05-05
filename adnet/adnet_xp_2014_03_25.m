S = test_q;
[score(1),ind(1)] = max(sum(S));
for nn = 2:size(test_q)
    S(ind(nn-1),:)=0;
    S(:,ind(nn-1))=0;
    [score(nn),ind(nn)] = max(sum(S));
end

for nn = 1:length(score)
    S = zeros(size(test_q));
    S(:,ind(1:nn)) = test_q(:,ind(1:nn));
    S = S | S';
    all_score(nn) = sum(sum(S))/sum(sum(test_q));
end
    