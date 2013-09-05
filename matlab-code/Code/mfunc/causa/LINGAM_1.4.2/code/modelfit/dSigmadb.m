% Compute dSigma_{ij}/b_{kl} first derivative of Sigma with respect to b
% by dSigmadb(i,j,k,l)

function y = dSigmadb(i,j,k,l, Y, D) 

dim = size(Y, 1);

% Optimization: calculate dYdb matrix - AK Feb 2006
dYdbMat = Y * D^(-1/2) * singleentryJ(dim, k, l) * Y;

% Optimization: calculate dYYdY matrix - AK Feb 2006
dYYdYMat = zeros(dim);
if i == j
  dYYdYMat(i, :) = 2 * Y(i, :);
else
  dYYdYMat(i, :) = Y(j, :);
  dYYdYMat(j, :) = Y(i, :);
end

y = sum(sum(dYdbMat .* dYYdYMat));
    
