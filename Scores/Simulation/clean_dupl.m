function [x, y] = clean_dupl(x_in, y_in)
% If you have duplicate values in x, take the max of corresponding y and go
% on.
x = unique(x_in);
n_un = length(x);

y = zeros(n_un,1);
for i = 1:n_un
    y(i) = max(y_in(x_in==x(i)));
end