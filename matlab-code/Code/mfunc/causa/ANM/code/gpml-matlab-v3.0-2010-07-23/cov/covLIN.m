function [A, B] = covLIN(hyp, x, z)

% Linear covariance function. The covariance function is parameterized as:
%
% k(x^p,x^q) = x^p'*x^q
%
% The are no hyperparameters:
%
% hyp = [ ]
%
% Note that there is no bias or scale term; use covConst to add these.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-21.
%
% See also COVFUNCTIONS.M.

if nargin<2, A = '0'; return; end                  % report number of parameters

if nargin==2
  A = x*x';
elseif nargout==2                                 % compute test set covariances
  A = sum(z.*z,2);
  B = x*z';
else                                               % compute derivative matrices
  A = [];
end
