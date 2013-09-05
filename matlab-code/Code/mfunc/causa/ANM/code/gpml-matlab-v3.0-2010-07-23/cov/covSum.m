function [A B] = covSum(cov, hyp, x, z)

% covSum - compose a covariance function as the sum of other covariance
% functions. This function doesn't actually compute very much on its own, it
% merely does some bookkeeping, and calls other covariance functions to do the
% actual work.
%
% Copyright (c) by Carl Edward Rasmussen & Hannes Nickisch 2009-12-17.
%
% See also COVFUNCTIONS.M.

for i = 1:numel(cov)                         % iterate over covariance functions
  f = cov(i); if iscell(f{:}), f = f{:}; end    % expand cell array if necessary
  j(i) = cellstr(feval(f{:}));                           % collect number hypers
end

if nargin<3                                        % report number of parameters
  A = char(j(1)); for i=2:length(cov), A = [A, '+', char(j(i))]; end; return
end

[n,D] = size(x);

v = [];               % v vector indicates to which covariance parameters belong
for i = 1:length(cov), v = [v repmat(i, 1, eval(char(j(i))))]; end

switch nargin
case 3                                               % compute covariance matrix
  A = zeros(n);                           % allocate space for covariance matrix
  for i = 1:length(cov)                       % iteration over summand functions
    f = cov(i); if iscell(f{:}), f = f{:}; end  % expand cell array if necessary
    A = A + feval(f{:}, hyp(v==i), x);                  % accumulate covariances
  end

case 4                       % compute derivative matrix or test set covariances
  if nargout == 2                                 % compute test set cavariances
    A = zeros(size(z,1),1); B = zeros(size(x,1),size(z,1));     % allocate space
    for i = 1:length(cov)
      f = cov(i); if iscell(f{:}) f = f{:}; end % expand cell array if necessary
      [AA BB] = feval(f{:}, hyp(v==i), x, z);         % compute test covariances
      A = A + AA; B = B + BB;                                   % and accumulate
    end
  else                                             % compute derivative matrices
    i = v(z);                                        % which covariance function
    j = sum(v(1:z)==i);                     % which parameter in that covariance
    f = cov(i);
    if iscell(f{:}), f = f{:}; end         % dereference cell array if necessary
    A = feval(f{:}, hyp(v==i), x, j);                       % compute derivative
  end
end