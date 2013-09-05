function [A, B] = covPeriodic(hyp, x, z)

% covariance function for a smooth periodic 1d functions, with unit period. The 
% covariance function is:
%
% k(x^p, x^q) = sf2 * exp( -2*sin^2( lam*(x_p-x_q)/(2*pi) )/ell^2 )
%
% where the hyperparameters are:
%
% hyp = [ log(ell)
%         log(lam)
%         log(sqrt(sf2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-02-23.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '3'; return; end                  % report number of parameters

n = size(x,1);
ell = exp(hyp(1));
lam = exp(hyp(2));
sf2 = exp(2*hyp(3));

if nargin==2
  A = sf2*exp(-2*(sin( lam*(repmat(x,1,n )-repmat(x',n,1))/(2*pi) )/ell).^2);
elseif nargout==2                                 % compute test set covariances
  ns = size(z,1);
  A = sf2*ones(ns,1);
  B = sf2*exp(-2*(sin( lam*(repmat(x,1,ns)-repmat(z',n,1))/(2*pi) )/ell).^2);
else                                               % compute derivative matrices
  r = lam*(repmat(x,1,n)-repmat(x',n,1))/(2*pi);
  if z==1
    r = (sin(r)/ell).^2;
    A = 4*sf2*exp(-2*r).*r;
  elseif z==2
    sre = sin(r)/ell;
    A = -4/ell*sf2*exp(-2*sre.^2).*sre.*cos(r).*r;
  else
    A = 2*sf2*exp(-2*(sin(r)/ell).^2);
  end
end
