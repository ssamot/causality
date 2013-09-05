function [A, B] = covRQard(hyp, x, z)

% Rational Quadratic covariance function with Automatic Relevance Determination
% (ARD) distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf2 * [1 + (x^p - x^q)'*inv(P)*(x^p - x^q)/(2*alpha)]^(-alpha)
%
% where the P matrix is diagonal with ARD parameters ell_1^2,...,ell_D^2, where
% D is the dimension of the input space, sf2 is the signal variance and alpha
% is the shape parameter for the RQ covariance. The hyperparameters are:
%
% hyp = [ log(ell_1)
%         log(ell_2)
%          ..
%         log(ell_D)
%         log(sqrt(sf2))
%         log(alpha) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-18.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '(D+2)'; return; end              % report number of parameters

[n,D] = size(x);
ell = exp(hyp(1:D));
sf2 = exp(2*hyp(D+1));
alpha = exp(hyp(D+2));

if nargin == 2
  K = (1+0.5*sq_dist(diag(1./ell)*x')/alpha);
  A = sf2*(K.^(-alpha));
elseif nargout == 2                               % compute test set covariances
  A = sf2*ones(size(z,1),1);
  B = sf2*((1+0.5*sq_dist(diag(1./ell)*x',diag(1./ell)*z')/alpha).^(-alpha));
else                                                 % compute derivative matrix
  K = (1+0.5*sq_dist(diag(1./ell)*x')/alpha);
  if z <= D                                            % length scale parameters
    A = sf2*K.^(-alpha-1).*sq_dist(x(:,z)'/ell(z));
  elseif z == D+1                                          % magnitude parameter
    A = 2*sf2*(K.^(-alpha));
  else
    A = sf2*K.^(-alpha).*(0.5*sq_dist(diag(1./ell)*x')./K - alpha*log(K));
  end
end