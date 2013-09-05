function [A, B] = covSEisoU(hyp, x, z)

% Squared Exponential covariance function with isotropic distance measure with
% unit magnitude. The covariance function is parameterized as:
%
% k(x^p,x^q) = exp(-(x^p - x^q)'*inv(P)*(x^p - x^q)/2) 
%
% where the P matrix is ell^2 times the unit matrix and sf2 is the signal
% variance. The hyperparameters are:
%
% hyp = [ log(ell) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-18.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '1'; return; end                  % report number of parameters

ell = exp(hyp(1));                                 % characteristic length scale
if nargin == 2
  A = exp(-sq_dist(x'/ell)/2);
elseif nargout == 2                               % compute test set covariances
  A = ones(size(z,1),1);
  B = exp(-sq_dist(x'/ell,z'/ell)/2);
else                                                 % compute derivative matrix
  A = exp(-sq_dist(x'/ell)/2).*sq_dist(x'/ell);  
end