% This creats a column vector from a matrix by stacking its columns
% and further removes its redundant elements
function y = vecplus(X)

n = size(X, 1);
mask = logical(triu(ones(n), 1));

y = X(:);
y(mask(:)) = [];
