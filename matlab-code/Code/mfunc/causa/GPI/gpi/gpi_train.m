function [DL,INFO] = gpi_train(X,Y,CFG)
% function [DL,INFO] = gpi_train(X,Y,CFG)
%
% Calculates the GPI in the direction X->Y.
% This function performs all the normalization out of the box.
% It runs both "standard GP regression" (additive noise) and the GPI regression. 
% The data is normalized first according to CFG.uniform
%
% INPUT:
%   X               Nx1 (hypothetical cause)
%   Y               Nx1 (hypothetical effect)
%   CFG             parameters; optional fields:
%     .minimize:      which minimizer to use (default: @minimize_lbfgsb)
%     .initE:         how to initialize E; true: using additive noise GP, false: randomly (default: true)
%     .Ncg:           number of conjugate gradient steps for GPI (default: 10000)
%     .NcgGP:         number of conjugate gradient steps for standard GP (default: CFG.Ncg)
%     .gradcheck:     whether initial gradient of cost function should be checked (default: false)
%                     this usually only passes if N is small, because of the jitter
%     .uniform:       true: normalize data to uniform, false: normalize data to Gaussian (default: false)
%     .epslabs:       regularization strength for logarithm in information term in cost function (default: 1e-3)
%     .profile:       whether the profiler should be enabled for the GPI optimization code (default: false)
%     .priors:        hyperparameters for prior on GP lengthscales (default: flat)
%     .cov:           initial values for GPI kernel hyperparameters (default: log([10;10;100]))
%     .scaleX:        scale factor for X (after normalization); (default: 1) experimental!
%     .scaleY:        scale factor for Y (after normalization); (default: 1) experimental!
%   CFG             parameters for gpi_objfun; optional fields:
%     .no_inf:        omit information term? (default: false)
%     .no_det:        omit GP determinant term? (default: false)
%     .barrier:       strength of barrier that penalizes negative df/de's in information term (default: 10)
%     .priors:        priors on GP hyperparameters (optional)
%     .jitter:        GP jitter; if negative, will be scaled with kernel magnitude (default: 1e-5)
%     .mask:          logical array with same size as cov; for each element of cov, if the corresponding
%                     element of CFG.mask is 1, then it should be included in the derivative (default: all ones)
%
% OUTPUT:
%   DL              final GPI cost function (= INFO.DL) for conditional model X->Y
%   INFO            detailed results
%     .X:             normalized X (input)
%     .Y:             normalized Y (output)
%     .hyp:           final hyperparameters (hyp.e is final residuals, hyp.cov final GPI kernel hyperparameters)
%     .CFG:           final CFG
%     .cost:          final cost function components (as returned by gpi_objfun)
%     .dfe:           final partial derivatives df/de
%     .a0:            cost function at initial hyperparameters
%     .b0:            cost function gradient at initial hyperparameters
%     .a1:            cost function at final hyperparameters
%     .b1:            cost function gradient at final hyperparameters
%     .DL:            final GPI cost function
%                       = cost.GP + cost.IT + cost.E + sum(cost.prior)
%     .GP:            results of initial standard (additive noise) GP
%       .hyp:           optimized hyperparameters
%       .lml:           optimized log-marginal-likelihood
%       .E:             normalized residuals
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  if nargin < 3
    CFG = struct;
  end;

  %set missing CFG fields to default values
  if ~isfield(CFG,'minimize');
    CFG.minimize = @minimize;
  end;
  if ~isfield(CFG,'initE')
    CFG.initE = true; 
  end;
  if ~isfield(CFG,'Ncg')
    CFG.Ncg = 10000;
  end;
  if ~isfield(CFG,'NcgGP')
    CFG.NcgGP = CFG.Ncg;
  end;
  if ~isfield(CFG,'gradcheck')
    CFG.gradcheck = false;
  end;
  if ~isfield(CFG,'uniform')
    CFG.uniform = false;
  end;
  if ~isfield(CFG,'epslabs')
    CFG.epslabs = 1e-3;
  end;
  if ~isfield(CFG,'profile')
    CFG.profile = false;
  end;
  if ~isfield(CFG,'cov')
    CFG.cov = log([10;10;100]);
  end;
  if ~isfield(CFG,'cov_f')
    CFG.cov_f = {@gpi_kernel_seard};
  end;

  INFO = struct();

  %normalize data
  if CFG.uniform
    X = normalize_(X,1);
    Y = normalize_(Y,1);
  else
    X = normalize_(X,2);
    Y = normalize_(Y,2);
  end
  if isfield(CFG,'scaleX')
    X = X * CFG.scaleX;
  end
  if isfield(CFG,'scaleY')
    Y = Y * CFG.scaleY;
  end

  %number of data points
  N = size(X,1);

  %fit standard GP X->Y for initialization of E
  hyp0GP.mean = [];
  hyp0GP.cov = log([0.4;1]); %log([ell;sf])
  hyp0GP.lik = log(0.2);     %log(sn)
  %optimize hyperparameters
  %%%hypGP = CFG.minimize(hyp0GP,'gp',-CFG.NcgGP,'infExact','meanZero','covSEiso','likGauss',X,Y);
  % The above code sometimes fails with matrix singularity errors when
  % L-BFGS is used. A work-around suggested by Joris Mooij is to use the
  % 'minimize' function instead, which supposed to be numerically more
  % stable.
  hypGP = minimize(hyp0GP,'gp',-CFG.NcgGP,'infExact','meanZero','covSEiso','likGauss',X,Y); 
  %calculate normalized residuals, which will be used as initial values for E
  [ymu,ys2] = gp(hypGP,'infExact','meanZero','covSEiso','likGauss',X,Y,X);
  E0 = (Y - ymu) / exp(hypGP.lik);
  %store results in INFO.GP
  INFO.GP.lml = gp(hypGP,'infExact','meanZero','covSEiso','likGauss',X,Y);
  INFO.GP.hyp = hypGP;
  INFO.GP.E = E0;

  hyp0 = struct();
  %initialize hyperparameters
  hyp0.cov = CFG.cov;
  %initialize E values
  if CFG.initE
    %initialise with E0
    hyp0.e = E0 / std(E0);
  else
    %initialise randomly
    hyp0.e = randn(size(E0));
  end;

  %check gradient
  if CFG.gradcheck
    success = gradcheck(hyp0,'gpi_objfun',CFG,CFG.cov_f,X,Y);
    if ~success
      error('gradcheck failed');
    end
  end;

  if CFG.profile
    profile on
  end

  % calculate GPI cost function and gradient at initial hyperparameters hyp0
  [INFO.a0,INFO.b0] = gpi_objfun(hyp0,CFG,CFG.cov_f,X,Y);
  % calculate optimized hyperparameters hyp, starting at initial ones hyp0
  hyp = CFG.minimize(hyp0,'gpi_objfun', -CFG.Ncg, CFG, CFG.cov_f, X, Y);
  % calculate GPI cost function and gradient at final (optimized) hyperparameters
  [INFO.a1,INFO.b1] = gpi_objfun(hyp,CFG,CFG.cov_f,X,Y);

  if CFG.profile
    profile off
  end

  %store things to plot
  INFO.X = X;
  INFO.Y = Y;

  %run again and store individual components of cost function:
  cost = gpi_objfun(hyp,CFG,CFG.cov_f,X,Y,true);
  INFO.cost = cost;          % final cost function components
  INFO.hyp = hyp;            % final optimized hyperparameters

  %calculate final partial derivatives df/de 
  INFO.dfe = gpi_predict(hyp,CFG,CFG.cov_f,X,Y,X,hyp.e,1);
  
  %store CFG structure
  INFO.CFG = CFG;            % configuration

  %calculate final DL
  INFO.DL = cost.GP + cost.IT + cost.E + sum(cost.prior);

  %return value
  DL = INFO.DL;

return
