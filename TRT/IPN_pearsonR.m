%% Computes the Pearson's R.
function [R]=IPN_pearsonR(X)
% X is a n*2 ratings matrix.
% n is the number of samples.

n = size(X,1);
x1 = X(:,1); x2 = X(:,2); 
P1 = dot (x1-mean(x1),x2-mean(x2));
P2 = (n-1)*std(x1)*std(x2);
R = P1/P2;