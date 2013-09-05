function [A, B] = covSEard(hyp, x, z)

% Squared Exponential covariance function with Automatic Relevance Detemination
% (ARD) distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf2 * exp(-(x^p - x^q)'*inv(P)*(x^p - x^q)/2)
%
% where the P matrix is diagonal with ARD parameters ell_1^2,...,ell_D^2, where
% D is the dimension of the input space and sf2 is the signal variance. The
% hyperparameters are:
%
% hyp = [ log(ell_1)
%         log(ell_2)
%          .
%         log(ell_D)
%         log(sqrt(sf2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-18.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '(D+1)'; return; end              % report number of parameters

[n,D] = size(x);
ell = exp(hyp(1:D));                               % characteristic length scale
sf2 = exp(2*hyp(D+1));                                         % signal variance

if nargin == 2
  K = sf2*exp(-sq_dist(diag(1./ell)*x')/2);
  A = K;                 
elseif nargout == 2                               % compute test set covariances
  A = sf2*ones(size(z,1),1);
  B = sf2*exp(-sq_dist(diag(1./ell)*x',diag(1./ell)*z')/2);
else                                                 % compute derivative matrix
  K = sf2*exp(-sq_dist(diag(1./ell)*x')/2);  
  if z <= D                                            % length scale parameters
    A = K.*sq_dist(x(:,z)'/ell(z));  
  else                                                     % magnitude parameter
    A = 2*K;
  end
end