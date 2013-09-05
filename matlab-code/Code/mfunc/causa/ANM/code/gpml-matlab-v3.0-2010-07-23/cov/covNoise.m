function [A, B] = covNoise(hyp, x, z)

% Independent covariance function, ie "white noise", with specified variance.
% The covariance function is specified as:
%
% k(x^p,x^q) = s2 * \delta(p,q)
%
% where s2 is the noise variance and \delta(p,q) is a Kronecker delta function
% which is 1 iff p=q and zero otherwise. The hyperparameter is
%
% hyp = [ log(sqrt(s2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-17.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '1'; return; end             % report number of hyperparameters

n = size(x,1);
s2 = exp(2*hyp);                                                % noise variance

if nargin==2                                         % compute covariance matrix
  A = s2*eye(n);
elseif nargout==2                                 % compute test set covariances
  A = s2*ones(size(z,1),1);
  B = zeros(n,size(z,1));               % zeros cross covariance by independence
else                                                 % compute derivative matrix
  A = 2*s2*eye(n);
end
