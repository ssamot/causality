% Compute dSigma_{ij}/d_{kk} first derivative of Sigma with respect to d
% by dSigmadd(i,j,k)

function y = dSigmadd(i,j,k, Y, D, B)

dim = size(Y, 1);

% Optimization: calculate dYdd matrix - AK Feb 2006
I = eye(dim);
dYddMat = Y * (D(k,k).^(-3/2) / 2) * singleentryJ(dim,k,k) * (I - B) * Y;

% Optimization: calculate dYYdY matrix - AK Feb 2006
dYYdYMat = zeros(dim);
if i == j
  dYYdYMat(i, :) = 2 * Y(i, :);
else
  dYYdYMat(i, :) = Y(j, :);
  dYYdYMat(j, :) = Y(i, :);
end

y = sum(sum(dYYdYMat .* dYddMat));
