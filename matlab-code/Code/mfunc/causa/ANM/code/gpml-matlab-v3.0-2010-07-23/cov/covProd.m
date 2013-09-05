function [A, B] = covProd(cov, hyp, x, z)

% covProd - compose a covariance function as the product of other covariance
% functions. This function doesn't actually compute very much on its own, it
% merely does some bookkeeping, and calls other covariance functions to do the
% actual work.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2009-12-18.
%
% See also COVFUNCTIONS.M.

for i = 1:length(cov)                        % iterate over covariance functions
  f = cov(i);
  if iscell(f{:}), f = f{:}; end           % dereference cell array if necessary
  j(i) = cellstr(feval(f{:}));
end

if nargin<3                                        % report number of parameters
  A = char(j(1)); for i=2:length(cov), A = [A, '+', char(j(i))]; end
  return
end

[n,D] = size(x);

v = [];               % v vector indicates to which covariance parameters belong
for i = 1:length(cov), v = [v repmat(i, 1, eval(char(j(i))))]; end

switch nargin
case 3                                               % compute covariance matrix
  A = ones(n, n);                         % allocate space for covariance matrix
  for i = 1:length(cov)                        % iteration over factor functions
    f = cov(i);
    if iscell(f{:}), f = f{:}; end         % dereference cell array if necessary
    A = A .* feval(f{:}, hyp(v==i), x);                   % multiply covariances
  end

case 4                       % compute derivative matrix or test set covariances
  if nargout == 2                                 % compute test set cavariances
    A = ones(size(z,1),1); B = ones(size(x,1),size(z,1));       % allocate space
    for i = 1:length(cov)
      f = cov(i);
      if iscell(f{:}), f = f{:}; end       % dereference cell array if necessary
      [AA BB] = feval(f{:}, hyp(v==i), x, z);         % compute test covariances
      A = A .* AA; B = B .* BB;                                 % and accumulate
    end
  else                                             % compute derivative matrices
    A = ones(n, n);
    ii = v(z);                                       % which covariance function
    j = sum(v(1:z)==ii);                    % which parameter in that covariance
    for i = 1:length(cov)
      f = cov(i);
      if iscell(f{:}), f = f{:}; end       % dereference cell array if necessary
      if i == ii
        A = A .* feval(f{:}, hyp(v==i), x, j);             % multiply derivative
      else
        A = A .* feval(f{:}, hyp(v==i), x);                % multiply covariance
      end
    end
  end

end