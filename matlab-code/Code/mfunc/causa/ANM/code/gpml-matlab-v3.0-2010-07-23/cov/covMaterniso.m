function [A, B] = covMaterniso(d, hyp, x, z)

% Matern covariance function with nu = d/2 and isotropic distance measure. For
% d=1 the function is also known as the exponential covariance function or the 
% Ornstein-Uhlenbeck covariance in 1d. The covariance function is:
%
%   k(x^p,x^q) = s2f * f( sqrt(d)*r ) * exp(-sqrt(d)*r)
%
% with f(t)=1 for d=1, f(t)=1+t for d=3 and f(t)=1+t+t²/3 for d=5.
% Here r is the distance sqrt((x^p-x^q)'*inv(P)*(x^p-x^q)), P is ell times
% the unit matrix and sf2 is the signal variance. The hyperparameters are:
%
% hyp = [ log(ell)
%         log(sqrt(sf2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-12.
%
% See also COVFUNCTIONS.M.

if nargin<3, A = '2'; return; end                  % report number of parameters

ell = exp(hyp(1));
sf2 = exp(2*hyp(2));
if all(d~=[1,3,5]), error('only 1, 3 and 5 allowed for d'), end  % degree

x = sqrt(d)*x/ell;

switch d
  case 1, f = @(t) 1;               df = @(t) 1;
  case 3, f = @(t) 1 + t;           df = @(t) t;
  case 5, f = @(t) 1 + t.*(1+t/3);  df = @(t) t.*(1+t)/3;
end
          k = @(t,f) f(t).*exp(-t); dk = @(t,f) df(t).*t.*exp(-t);

if nargin==3                                         % compute covariance matrix
  A = sf2*k( sqrt(sq_dist(x')), f );
elseif nargout==2                                 % compute test set covariances
  A = sf2*ones(size(z,1),1);
  B = sf2*k( sqrt(sq_dist(x',sqrt(d)*z'/ell)), f );
else                                               % compute derivative matrices
  if z==1
    A =   sf2*dk( sqrt(sq_dist(x')), f );
  else
    A = 2*sf2* k( sqrt(sq_dist(x')), f );
  end
end
