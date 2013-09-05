function [Ys,VYs] = gpi_predict(hyp,CFG,cov_f,X,Y,Xs,Es,deriv)
% function Ys = gpi_predict(hyp,CFG,cov_f,X,Y,Xs,Es)
%
% Uses a fitted GPI f to predict Ys = f(Xs,Es) on new data (Xs,Es)
%
% INPUT
%   hyp:   hyperparameters of the covariance function
%   CFG:   cfg structure
%   cov_f: covariance function
%   X/Y:   dataset (N x 1)
%   Xs:    test inputs (M x 1)
%   Es:    test noise level (M x 1)
%   deriv: derivative predictions (true) or function values (false)
% 
% OUTPUT:
%   Ys:    mean prediction of GP
%   VYS:   predicted variance of GP (more expensive)
% 
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

if nargin <8
  deriv = false;
end;

%jitter parameter
jitter = CFG.jitter;

%calculate GP kernel, cholesky decomposition and alpha
cov_f_CFG = [];
cov_f_CFG.jitter = CFG.jitter;
cov_f_CFG = feval(cov_f{:},cov_f_CFG,hyp.cov,X,hyp.e);
cov_f_CFG.alpha = solve_chol(cov_f_CFG.L',Y);

%calculate cross covariance and make predictions:
cov_f_CFG = feval(cov_f{:},cov_f_CFG,hyp.cov,Xs,Es,0,deriv,X, ...
                  hyp.e);

%make mean prediction:
Ys = cov_f_CFG.cK * cov_f_CFG.alpha;

if nargout==2
  %predictive variances requested?
  %1. self covariance 
  cov_f_CFG_Kss = [];
  cov_f_CFG_Kss.jitter = CFG.jitter;
  cov_f_CFG_Kss = feval(cov_f{:},cov_f_CFG_Kss, hyp.cov,Xs,Es);
  v = cov_f_CFG.L\ cov_f_CFG.cK';
  VYs = diag(cov_f_CFG_Kss.K) - sum(v.*v)';
end;

return
