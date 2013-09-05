function plot_fitted_model(INFO_XY,INFO_X,nameX,nameY)
% function plot_fitted_model(INFO_XY,INFO_X,nameX,nameY)
%
% Visualizes a fitted model for p(X,Y)
%
% INPUT:
%   INFO_XY:   struct output by e.g. by gpi_train
%   INFO_X:    struct output by e.g. by mmlgmm
%   nameX:     name for X (default: 'X')
%   nameY:     name for Y (default: 'Y')
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  if nargin < 3
    nameX = 'X';
  end
  if nargin < 4
    nameY = 'Y';
  end

  X = INFO_XY.X;
  Y = INFO_XY.Y;

  fprintf('Cost p(%s | %s):\n',nameX,nameY);
  INFO_XY.cost
  fprintf('Cost p(%s): %f\n',nameX,INFO_X.DL);

  figure;

  subplot(2,2,1);
  surf_plot(INFO_XY,false,nameX,nameY);
  title(sprintf('Function f : (%s,E)->%s',nameX,nameY));

  subplot(2,2,2);
  contour_plot(INFO_XY,nameX,nameY);
  title(sprintf('Conditional p(%s|%s)',nameY,nameX));

  dfe = [];
  dfe = INFO_XY.dfe;
  if ~isempty(dfe)
    subplot(2,2,3);
    surf_plot(INFO_XY,true,nameX,nameY);
    title('Derivative df/de');
  end

  subplot(2,2,4);
  hist_plot(INFO_X,length(INFO_X.X) / 10,nameX);
  title(sprintf('Input p(%s)',nameX));
return
