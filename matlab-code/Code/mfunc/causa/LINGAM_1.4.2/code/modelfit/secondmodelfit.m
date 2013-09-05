%second-order model fit
%Shohei Shimizu Feb 2006
%for lingam paper

% X is a data matrix. B is a connection strength matrix, Ve is a covariance
% matrix of disturbances
% Very important. Give a strictly lower triangular B to this code!!
function [chi,df,pvalue] = secondmodelfit(X,B,Ve)

% dim is dimension, sample is sample size
[dim, sample] = size(X);

% Center X
X = X-mean(X')'*ones(1,sample);
    
% Calculate sample covariance matrix S and its redundancy-removed-version
% vector m2
S = cov(X');
m2 = vecplus(S);

% Calculate sample covariance matrix of m2, named V
% Optimization: do it without 'vecplus' to avoid calculating 'mask'
% in every iteration - AK Feb 2006
t = zeros( dim * (dim + 1) / 2, sample);
mask = logical(triu(ones(dim), 1));  % Mask for redundant elements
mask = mask(:);
for i = 1 : sample,
  ti = X(:,i)*X(:,i)';
  ti = ti(:);
  ti(mask) = [];  % Remove redundant elements
  t(:,i) = ti;
end

V = cov(t');

% Calculate model-based covariance matrix Sigma and its
% redundancy-removed-version vector sigma2
I = eye(dim);
D = Ve;
Y = (D^(-1/2)*(I-B))^(-1);

Sigma = Y*Y';
sigma2 = vecplus(Sigma);

% Compute a weight matrix M
invV = inv(V);
J = computeJ(Y, B, Ve);
M = invV - invV * J * (J' * invV * J)^(-1) * J' * invV;

% Compute a test statistic T1
F = (m2-sigma2)' * M * (m2-sigma2);
T1 = sample * F;

% Apply Yuan-Bentler correction
T2 = T1 / (1 + F);
chi = T2;

% degrees of freedom
nofmoments = dim * (dim + 1) / 2;
nofparameters = sum(sum(B ~= 0)) + sum(sum(Ve ~= 0));
df =  nofmoments - nofparameters;

if df == 0
    % In Octave, chi2cdf can not be called with df = 0,
    % so treat it as a special case.
    pvalue = 0;
else
    % Compute p value
    pvalue = 1 - chi2cdf(chi, df);
end
