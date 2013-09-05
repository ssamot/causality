function [A, B] = covConst(hyp, x, z)

% covariance function for a constant function. The covariance function is
% parameterized as:
%
% k(x^p,x^q) = s2;
%
% The scalar hyperparameter is:
%
% hyp = [ log(sqrt(s2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-21.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '1'; return; end                  % report number of parameters

s2 = exp(2*hyp);                                                            % s2
n = size(x,1);

if nargin==2
  A = s2*ones(n,n);
elseif nargout==2 && nargin==3                    % compute test set covariances
  ns = size(z,1);
  A = s2*ones(ns,1);
  B = s2*ones(n,ns);
else                                                 % compute derivative matrix
  A = 2*s2*ones(n,n);
end

