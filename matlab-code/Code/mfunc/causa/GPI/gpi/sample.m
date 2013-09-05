function x = sample(type,N,pars)
% function x = sample(type,N,pars)
%
% Returns a sample from a probability distribution
% 
%   type = 'nongauss':    pars is power
%   type = 'exponential'
%   type = 'laplacian'
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%

  if strcmp(type,'nongauss')
    x = abs(randn(N,1)).^pars .* sign(randn(N,1));
    x = x / std(x);
  elseif strcmp(type,'exponential')
    x = -log(rand(N,1)) - 1.0;
    x = x / std(x);
  elseif strcmp(type,'laplacian')
    x = laprnd(ones(N,1));
    x = x / std(x);
  else
    error('sample: Unknown type');
  end

return
