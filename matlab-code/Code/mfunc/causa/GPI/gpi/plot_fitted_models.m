function [INFO_XY,INFO_YX,INFO_X,INFO_Y] = plot_fitted_models(fname)
% function [INFO_XY,INFO_YX,INFO_X,INFO_Y] = plot_fitted_models(fname)
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  load(fname);

  plot_fitted_model(INFO_XY,INFO_X,'X','Y');
  plot_fitted_model(INFO_YX,INFO_Y,'Y','X');
  DL_XY = INFO_XY.DL + INFO_X.DL;
  DL_YX = INFO_YX.DL + INFO_Y.DL;
  fprintf('Causal direction (positive means X->Y): %f\n', -(DL_XY - DL_YX));
  fprintf('Causal direction, ignoring prior cost (positive means X->Y): %f\n', -((DL_XY - sum(INFO_XY.cost.prior)) - (DL_YX - sum(INFO_YX.cost.prior))));

return
