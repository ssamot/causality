function [Yfit] = fit_gp(X,Y,ard)
% function [Yfit] = fit_gp(X,Y,ard)
%
% Fits a Gaussian Process with RBF kernel to the pairs (X,Y)
%
% INPUT:  X    should be N*d matrix (N data points, d dimensions)
%         Y    should be N*1 matrix (N data points)
%         ard  if 1, use covSEard, otherwise covSEiso (default)
%
% OUTPUT: Yfit contains the fitted y values
%
% NOTE:   Uses GPML 3.0 code (which should be in the matlab path)
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  % check input arguments
  if size(Y,2)~=1 | size(X,1)~=size(Y,1)
    error('X should be Nxd and Y should be Nx1');
  end
  if nargin < 3 || isempty(ard)
    ard = 0;
  end

  % setup the GP

  % set covariance function
  if ard == 1
    cov = {@covSEard}; % automatic relevance detection
  else
    cov = {@covSEiso};
  end

  % set mean function
  mean = {@meanZero};

  % set likelihood
  lik = 'likGauss';

  % init hyperparameters
  sf  = 1.0;  % sigma_function
  ell = 1.0;  % length scale
  sn  = 0.1;  % sigma_noise
  hyp.lik = log(sn);
  if ard == 1
    hyp.cov = log([ell * ones(size(X,2),1);sf]);
  else
    hyp.cov = log([ell;sf]);
  end

  % learn hyperparameters
  Ncg = 1000;  % number of conjugate gradient steps
  hyp = minimize(hyp,'gp',-Ncg,'infExact',mean,cov,lik,X,Y);
  %hyp = minimize_lbfgsb(hyp,'gp',-Ncg,'infExact',mean,cov,lik,X,Y);

  % calculate evidence (log marginal likelihood)
  lml = -gp(hyp,'infExact',mean,cov,lik,X,Y); % calculate evidence

  % calculate fit on training set
  [Yfit] = gp(hyp,'infExact',mean,cov,lik,X,Y,X);

return
