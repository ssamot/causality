function contour_plot(INFO_XY,nameX,nameY)
% function contour_plot(INFO_XY,nameX,nameY)
%
% Visualizes a GPI f : (X,E) -> Y by a contour plot
%
% INPUT:
%   INFO_XY:   struct output by e.g. by gpi_train
%   nameX:     name for X (default: 'X')
%   nameY:     name for Y (default: 'Y')
% 
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%

  if nargin < 2
    nameX = 'X';
  end
  if nargin < 3
    nameY = 'Y';
  end

  X = INFO_XY.X;
  Y = INFO_XY.Y;
  E = INFO_XY.hyp.e;
  hyp = INFO_XY.hyp;
  CFG = INFO_XY.CFG;
  jitter = INFO_XY.CFG.jitter;
  %calculate GP kernel, cholesky decomposition and alpha
  
  %mean predictions
  Y_ = gpi_predict(hyp,CFG,CFG.cov_f,X,Y,X,hyp.e,0);
  
  fprintf('norm of "residuals": %f\n',norm(Y-Y_));

  %mesh grid
  Xs = linspace(min(X),max(X),50);
  plot(X,Y,'.');
  xlabel(nameX);
  ylabel(nameY);
  Econtours = [-1.2816 -0.8416 -0.5244 -0.2533 0 0.2533 0.5244 0.8416 1.2816];
  ps = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
  hold on;
  for cnt = 1:length(Econtours);
    Es = ones(size(Xs)) * Econtours(cnt);  
    Zs = gpi_predict(hyp,CFG,CFG.cov_f,X,Y,Xs(:),Es(:),0);  
    col = abs(0.5 - ps(cnt)) / 0.5;
    plot(Xs,Zs,'-','Color',[col col col]);
  end
  plot(X,Y,'.');
  hold off;

return
