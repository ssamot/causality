function [A, B] = covScale(cov, hyp, x, z)

% meanScale - compose a mean function as a scaled version of another one.
%
% k(x^p,x^q) = sf^2 * k_0(x^p,x^q)
%
% The hyperparameter is:
%
% hyp = [ log(sf)  ]
%
% This function doesn't actually compute very much on its own, it merely does
% some bookkeeping, and calls other mean function to do the actual work.
%
% Copyright (c) by Carl Edward Rasmussen & Hannes Nickisch 2010-07-15.
%
% See also MEANFUNCTIONS.M.

if nargin<3                                        % report number of parameters
  A = [feval(cov{:}),'+1']; return
end

[n,D] = size(x);
sf2 = exp(2*hyp(1));                                           % signal variance

if nargin==3
  A = sf2*feval(cov{:},hyp(2:end),x);
elseif nargout==2                                 % compute test set covariances
  [A, B] = feval(cov{:},hyp(2:end),x,z); A = sf2*A; B = sf2*B;
else                                                 % compute derivative vector
  if z==1
    A = 2*sf2*feval(cov{:},hyp(2:end),x);
  else
    A = sf2*feval(cov{:},hyp(2:end),x,z-1);
  end
end