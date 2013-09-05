function [DL,INFO] = mmlgmm(X,CFG)
% function [DL,INFO] = mmlgmm(X,CFG)
%
% Wrapper to invoke the Miminum Message Length Gaussian Mixture Model code 
% written by M. Figueiredo and A.K.Jain, described in the paper
% M. Figueiredo and A.K.Jain, "Unsupervised learning of
% finite mixture models",  IEEE Transaction on Pattern Analysis
% and Machine Intelligence, vol. 24, no. 3, pp. 381-396, March 2002.
%
% INPUT:
%   X               Nx1 sample
%   CFG             parameters; optional fields:
%     reg             regularizer value (default: 1e-4)
%     maxclusters     maximum number of Gaussian mixture components (default: 50)
%
% OUTPUT:
%   DL:             minimum description length (up to O(1))
%   INFO:           detailed results
%     .X:             copy of X
%     .CFG:           copy of CFG
%     .DL:            minimum description length (up to O(1)), equal to DL
%     .k:             number of Gaussian mixture components
%     .pp:            weights of Gaussian mixture components
%     .mu:            means of Gaussian mixture components
%     .cov:           covariance matrices of Gaussian mixture components
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING.GPL2 for license terms.

  if nargin < 3
    CFG = struct;
  end;
  
  if ~isfield(CFG,'reg')
    CFG.reg = 1e-4;
  end;
  if ~isfield(CFG,'maxclusters')
    CFG.maxclusters = 50;
  end;

  assert(size(X,2) == 1);
  ready = false;
  INFO = struct;
  maxclusters = CFG.maxclusters;
  while ~ready
    try
      [bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4(X',1,maxclusters,CFG.reg,1e-9,0);
      INFO.DL = min(dl);
      INFO.k = bestk;
      INFO.pp = bestpp;
      INFO.mu = bestmu;
      INFO.cov = bestcov;
      INFO.X = X;
      ready = true;
    catch ME
      if strcmp(ME.identifier,'mixtures4:error')
        maxclusters = maxclusters - 1;
        if maxclusters == 0
          error('maxclusters became 0');
        end
      else
        rethrow(ME);
      end
    end
  end

  INFO.CFG = CFG;
  DL = INFO.DL;

return
