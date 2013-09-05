function [DL,INFO_XY,INFO_X] = gpi_mml(X,Y,CFG_XY,CFG_X)
% function [DL,INFO_XY,INFO_X] = gpi_mml(X,Y,CFG_XY,CFG_X)
%
% This function calculates the "evidence" for the DAG X->Y
% by using MML with GMM for p(X) and GPI for p(Y | X)
%
% INPUT:
%   X:              Nx1 (hypothetical cause)
%   Y:              Nx1 (hypothetical effect)
%   CFG_XY:         CFG struct expected by e.g. gpi_train
%   CFG_X:          CFG struct expected by e.g. mmlgmm
%
% OUTPUT:
%   DL:             total description length for p(X,Y)
%   INFO_XY:        INFO struct returned by e.g. gpi_train
%   INFO_X:         INFO struct returned by e.g. mmlgmm
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING.GPL2 for license terms.

  if nargin < 3
    CFG_XY = struct;
  end
  if nargin < 4
    CFG_X = struct;
  end

  % run GPI
  [DL_GPI,INFO_XY] = gpi_train(X,Y,CFG_XY);

  % run MMLGMM (on the X preprocessed by gpi_train)
  [DL_MML,INFO_X] = mmlgmm(INFO_XY.X,CFG_X);
  
  % calculate total description length
  DL = DL_GPI + DL_MML;

return
