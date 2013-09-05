function [A, B] = covPoly(d, hyp, x, z)

% Polynomial covariance function. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf^2 * ( c + (x^p)'*(x^q) )^d 
%
% The hyperparameters are:
%
% hyp = [ log(c)
%         log(sf)  ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-12.
%
% See also COVFUNCTIONS.M.

if nargin<3, A = '2'; return; end                  % report number of parameters

c = exp(hyp(1));                                          % inhomogeneous offset
sf2 = exp(2*hyp(2));                                           % signal variance
if d~=max(1,fix(d)), error('only nonzero integers allowed for d'), end  % degree

if nargin==3
  A = sf2*( c + x*x' ).^d;
elseif nargout==2                                 % compute test set covariances
  A = sf2*( c + sum(z.^2,2) ).^d;
  B = sf2*( c + x*z' ).^d;
else                                                 % compute derivative matrix
  if z==1                                                      % first parameter
    A = c*d*sf2*( c + x*x' ).^(d-1);  
  else                                                        % second parameter
    A = 2*sf2*( c + x*x' ).^d;
  end
end