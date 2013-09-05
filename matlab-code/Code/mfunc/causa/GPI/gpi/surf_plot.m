function surf_plot(INFO_XY,deriv,nameX,nameY)
% function surf_plot(INFO_XY,deriv)
% 
% Visualizes a GPI f : (X,E) -> Y by a surface plot
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
    deriv = false;
  end;

  if nargin < 3
    nameX = 'X';
  end
  if nargin < 4
    nameY = 'Y';
  end

  %get X,Y and fitted E
  X = INFO_XY.X;
  Y = INFO_XY.Y;
  E = INFO_XY.hyp.e;
  hyp = INFO_XY.hyp;
  CFG = INFO_XY.CFG;
  
  cov_f = {@gpi_kernel_seard};
  
  %mesh grid
  [Xs,Es] = meshgrid(linspace(min(X),max(X),50),linspace(min(E), ...
                                                    max(E),50));
  %predict at meshgrid coordinates
  [Zs] = gpi_predict(hyp,CFG,cov_f,X,Y,Xs(:),Es(:),deriv);
  surfc(Xs,Es,reshape(Zs(:),length(Xs),length(Es)));  
  hold on;
  
  if deriv
    dfe = gpi_predict(hyp,CFG,cov_f,X,Y,X,hyp.e,deriv);
    plot3(X,E,dfe,'ko');
    zlabel('dfdE');
  else
    plot3(X,E,Y,'ko');
    zlabel(nameY);
  end;
  hold off;
  xlabel(nameX);
  ylabel('E');
  
  
