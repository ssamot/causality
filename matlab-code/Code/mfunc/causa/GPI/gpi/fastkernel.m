function [A] = fastkernel(X,E,l_X,l_E,sf2,mode,X2,E2)
% function [A] = fastkernel(X,E,l_X,l_E,sf2,mode,X2,E2)
%
% Calculates a kernel matrix K which is the product of two RBF kernels:
% or the derivative matrix dKde := d/de1 k((x1,e1),(x2,e2))
%
%  K = sf2 * exp(-sq_dist(X'/l_X,X2'/l_X) / 2) .* exp(-sq_dist(E'/l_E,E2'/l_E) / 2);
%  dKde = -K .* (dist(E,E2) / (l_E * l_E));
%
% For faster calculations, there is also a C++ implementation of this
% function. If the corresponding MEX file has been built, it will be 
% used by MatLab instead of the slower MatLab implementation.
%
% INPUT:    X      = Nx1 vector of doubles
%           E      = Nx1 vector of doubles
%           l_X    = length scale for X
%           l_E    = length scale for E
%           sf2    = magnitude squared
%           mode   = 0 or 1
%           X2     = N2x1 vector of doubles (optional; default = X)
%           E2     = N2x1 vector of doubles (optional; default = E)
%
% OUTPUT:   A      = NxN matrix (K if mode == 0, dKde if mode == 1)
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  if nargin < 7
    X2 = X;
    E2 = E;
  end

  K = sf2 * exp(-sq_dist(X'/l_X,X2'/l_X) / 2) .* exp(-sq_dist(E'/l_E,E2'/l_E) / 2);
  if mode == 0
    A = K;
  elseif mode == 1
    A = K .* (dist(E,E2) / (-l_E * l_E));
  else
    error('Unknown mode');
  end

return
