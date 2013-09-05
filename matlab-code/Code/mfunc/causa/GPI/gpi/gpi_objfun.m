function [lml,dlml] = gpi_objfun(hyp,CFG,cov_f,X,Y,components)
% function [lml,dlml] = gpi_objfun(hyp,CFG,cov_f,X,Y,components)
%
% Calculate cost function and gradient for GPI criterion
% at specified noise values and GP hyperparameters
%
% INPUT:
%   hyp:          hyperparameters
%     .e:           noise values
%     .cov:         GP hyperparameters
%   CFG:          configuration parameters
%     .no_inf:      omit information term? (default: false)
%     .no_det:      omit GP determinant term? (default: false)
%     .epslabs:     regularization strength of logarithm in IT cost term (default: 1e-3)
%     .barrier:     strength of barrier that penalizes negative df/de's in information term (default: 10)
%     .priors:      priors on GP hyperparameters (optional)
%     .jitter:      GP jitter (default: 1e-5)
%     .mask:        logical array with same size as hyp.cov; for each element of hyp.cov, if the corresponding
%                   element of CFG.mask is 1, then it should be included in the derivative (default: all ones)
%   cov_f:        covariance function (e.g., gpi_kernel_seard)
%   X:            Nx1 input (hypothetical cause)
%   Y:            Nx1 output (hypothetical effect)
%   components:   if true, return each component of the cost function seperately (default: false)
%
% OUTPUT (components == true):
%   lml           cost function struct
%     .GP           GP term
%     .E            entropy of E term
%     .IT           information term
%     .prior        prior terms
%   dlml          cost function gradient
%     .GP           GP term
%     .E            entropy of E term
%     .IT           information term
%     .prior        prior terms
%
% OUTPUT (components == false):
%   lml:          total GPI cost function
%   dlml.e        total GPI cost function gradient with respect to noise values
%   dlml.cov      toatl GPI cost function gradient with respect to GP hyperparameters
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  %complement missing input arguments
  if nargin < 6
    components=false;
  end;

  %set default CFG values
  if ~isfield(CFG,'no_inf')
    CFG.no_inf = false;
  end;
  if ~isfield(CFG,'no_det')
    CFG.no_det = false;
  end;
  if ~isfield(CFG,'epslabs')
    CFG.epslabs = 1e-3;
  end;
  if ~isfield(CFG,'barrier')
    CFG.barrier = 10;
  end;
  if ~isfield(CFG,'jitter')
    CFG.jitter = 1e-5;
  end
  if ~isfield(CFG,'mask')
    CFG.mask = ones(size(hyp.cov));
  end;

  %create full covariance hyperparameters, including E
  hyp_cov = [hyp.cov;hyp.e];

  %calculate GP kernel, cholesky decomposition and alpha
  %and store them in cov_f_CFG because we will need them more than once
  cov_f_CFG = [];
  cov_f_CFG.jitter = CFG.jitter;
  cov_f_CFG = feval(cov_f{:},cov_f_CFG,hyp.cov,X,hyp.e);
  cov_f_CFG.alpha = solve_chol(cov_f_CFG.L',Y);
  cov_f_CFG.Kinv = cov_f_CFG.L'\(cov_f_CFG.L\eye(size(cov_f_CFG.K,1)));
  cov_f_CFG.dKde_Kinv = -cov_f_CFG.dKde * cov_f_CFG.Kinv;

  %calculate various terms in cost function

  %1. GP cost function:
  [lml_GP,dlml_GP] = cf_GP(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG);

  %2. entropy cost function
  [lml_E,dlml_E] = cf_E(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG);

  %3. information term, if requested
  if CFG.no_inf
    lml_IT = 0;
    dlml_IT = zeros(size(hyp_cov));
  else
    [lml_IT,dlml_IT] = cf_IT(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG);
  end;

  %4. prior, if requested
  lml_prior = zeros(3,1);
  dlml_prior = zeros(3,1);
  if isfield(CFG,'priors')
    %priors only on lengthscale X,E:
    for i=1:3
      [g,dg] = lngammapdf(exp(hyp_cov(i)),CFG.priors{i});
      lml_prior(i) = -g;
      dlml_prior(i) = -dg*exp(hyp_cov(i));
    end;
  end;

  % apply mask
  for i=1:length(CFG.mask)
    if ~CFG.mask(i)
      dlml_GP(i) = 0;
      dlml_IT(i) = 0;
      dlml_prior(i) = 0;
    end
  end

  % if requested, return cost function components
  if components
    lml = struct();
    lml.GP = lml_GP;
    lml.E  = lml_E;
    lml.IT = lml_IT;
    lml.prior = lml_prior;
    dlml = struct();
    dlml.GP = dlml_GP;
    dlml.E  = dlml_E;
    dlml.IT = dlml_IT; 
    dlml.prior = dlml_prior;
  else
    lml = lml_E + lml_GP + lml_IT + sum(lml_prior);
    dlml = struct();
    dlml.e = dlml_E + dlml_GP(4:end) + dlml_IT(4:end);
    dlml.cov = dlml_GP(1:3) + dlml_IT(1:3) + dlml_prior;
  end;
return


function [lml_E,dlml_E] = cf_E(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG)
% entropy term (negative log-likelihood of E under standard Gaussian distribution)
% and its gradient with respect to E
  [n,D]  = size(X);

  %sigma2 can be fixed to one without loss of generality:
  sigma2 = 1.0;
  %alternatively, one could take sigma from the GP hyperparameters:
  %sigma2 = exp(2*hyp_cov(3));

  E      = hyp_cov(4:end);
  lml_E  = 0.5 * n * log(2*pi*sigma2) + 0.5 * sum(E.^2) / sigma2;
  dlml_E = E / sigma2;
return


function [lml_GP,dlml_GP] = cf_GP(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG)
% GP term (negative log-likelihood of Y under GP conditioned on X,E)
% and its gradient with respect to hyp_cov

  [n,D] = size(X);

  hyp = hyp_cov(1:3);
  E = hyp_cov(4:end);

  alpha = cov_f_CFG.alpha;
  L = cov_f_CFG.L;

  if CFG.no_det
    lml_GP = 0.5*Y'*alpha + 0.5*n*log(2*pi);
  else
    lml_GP = 0.5*Y'*alpha + sum(log(diag(L))) + 0.5*n*log(2*pi);
  end

  dlml_GP = zeros(size(hyp_cov));
  if CFG.no_det
    W = -alpha*alpha';  % is symmetric
  else
    W = cov_f_CFG.Kinv - alpha*alpha';  % is symmetric
  end

  d = 3; % number of GP hyperparameters
  for i=1:d
    dK_i = feval(cov_f{:},cov_f_CFG,hyp,X,E,i,0);
    dlml_GP(i) = sum(sum(W .* dK_i)) / 2;
  end;
  % optimized for "noise" hyperparameters
  e = hyp_cov(d+1:end);
  for ei=1:n
    dK_ei = feval(cov_f{:},cov_f_CFG,hyp,X,E,-ei,0);
    dlml_GP(ei+d) = dK_ei * W(:,ei);
  end;
return


function [lml_IT,dlml_IT] = cf_IT(CFG,hyp_cov,cov_f,X,Y,cov_f_CFG)
% information term:
% calculates sum over data points of logarithms of absolute values
% of partial derivatives of the mean GP with respect to the noise
% and its gradient with respect to hyp_cov
%
% approximates the absolute value |x| by sqrt((x-eps)^2 + eps)
% where eps = CFG.epslabs
%
% also, adds a strong penalty for values x < eps

  [n,D] = size(X);

  %shortcuts
  eps_dfe = CFG.epslabs;
  alpha = cov_f_CFG.alpha;
  KKd1 = cov_f_CFG.KKd1;
  L = cov_f_CFG.L;

  hyp = hyp_cov(1:3);
  E = hyp_cov(4:end);

  %mean derivative predictions
  dfe = cov_f_CFG.dKde * alpha;

  %make this differentiable at 0 (simplifies numerical optimization)
  dfe  = dfe - eps_dfe;
  adfe = sqrt(dfe.^2+eps_dfe);

  %enforce positivity of df/de terms:
  p_constraint = CFG.barrier * (log(adfe) - log(sqrt(eps_dfe))) .* (dfe < 0);
  lml_IT = sum(log(adfe)) + sum(p_constraint);

  %calculate derivative terms
  dlml_IT = zeros(size(hyp_cov));

  d = 3; % number of GP hyperparameters
  for i=1:length(hyp_cov)
    if i <= d
      Kcd = feval(cov_f{:},cov_f_CFG,hyp,X,E,i,1);
      dK = feval(cov_f{:},cov_f_CFG,hyp,X,E,i,0);

      dfei_1 = Kcd * alpha;
      dK_alpha = dK * alpha;
    else % optimized for noise "hyperparameters"
      ei = i - d;
      Kcd_i = feval(cov_f{:},cov_f_CFG,hyp,X,E,-ei,1);
      dK_i = feval(cov_f{:},cov_f_CFG,hyp,X,E,-ei,0);

      dfei_1 = -Kcd_i' * alpha(ei);
      dfei_1(ei) = dfei_1(ei) + Kcd_i * alpha;
      dK_alpha = dK_i' * alpha(ei);
      dK_alpha(ei) = dK_alpha(ei) + dK_i * alpha;
    end
    dfei_2 = cov_f_CFG.dKde_Kinv * dK_alpha;
    dfei = dfei_1 + dfei_2;
    %derivative of abs log (log adfe):
    dd = dfei .* dfe ./ (dfe.^2 + eps_dfe);
    % dd = (dfei_1+dfei_2).*sign(dfe)./(abs(dfe)+add_dfe);
    %derivative of positivity constraint:
    dp = CFG.barrier * dd .* (dfe < 0);
    dlml_IT(i) = sum(dd + dp);
  end;
return
