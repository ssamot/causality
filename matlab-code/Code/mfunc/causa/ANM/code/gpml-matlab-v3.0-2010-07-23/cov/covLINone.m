function [A, B] = covLINone(hyp, x, z)

% Linear covariance function with a single hyperparameter. The covariance
% function is parameterized as:
%
% k(x^p,x^q) = (x^p'*x^q + 1)/t2;
%
% where the P matrix is t2 times the unit matrix. The second term plays the
% role of the bias. The hyperparameter is:
%
% hyp = [ log(sqrt(t2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-18.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '1'; return; end                  % report number of parameters

it2 = exp(-2*hyp);                                                  % t2 inverse

if nargin==2                                                % compute covariance
  A = it2*(1+x*x');
elseif nargout==2                                 % compute test set covariances
  A = it2*(1+sum(z.*z,2));
  B = it2*(1+x*z');
else                                                 % compute derivative matrix
  A = -2*it2*(1+x*x');
end
