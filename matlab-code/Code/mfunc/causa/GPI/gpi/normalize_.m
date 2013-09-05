function Z = normalize_(X,criterion)
% function Z = normalize_(X,criterion)
%
% Returns a normalized version of X:
%   if criterion == 1, each column is scaled and shifted such that it has mean 0 and the difference between maximum and minimum equals 1
%   if criterion == 2, each column is scaled and shifted such that it has mean 0 and variance 1 (default)
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%

  if nargin < 2
    criterion = 2;
  end;

  N = size(X,1);

  if criterion == 1
    maxX = max(X);
    minX = min(X);
    Z = (X - ones(N,1) * mean(X)) ./ (ones(N,1) * (maxX - minX));
  elseif criterion == 2
    Z = (X - ones(N,1) * mean(X)) ./ (ones(N,1) * std(X));
  else
    error('Unknown normalization criterion');
  end

return
