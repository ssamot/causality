function f = igci(x,y,refMeasure,estimator)
% Performs causal inference in a deterministic scenario (see [1] for details)
% Information Geometric Causal Inference (IGCI)
%
% USAGE:
%   f = igci(x,y,refMeasure,estimator)
% 
% INPUT:
%   x          - m x 1 observations of x
%   y          - m x 1 observations of y
%   refMeasure - reference measure to use:
%                  1: uniform
%                  2: Gaussian
%   estimator -  estimator to use:
%                  1: entropy (eq. (12) in [1]),
%                  2: integral approximation (eq. (13) in [1]).
% 
% OUTPUT: 
%   f > 0:       the method prefers the causal direction x -> y
%   f < 0:       the method prefers the causal direction y -> x
% 
% EXAMPLE: 
%   x = randn(100,1); y = exp(x); igci(x,y,2,1) > 0
%
%
% Copyright (c) 2010  Povilas Daniušis, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
% ----------------------------------------------------------------------------
%
% [1]  P. Daniušis, D. Janzing, J. Mooij, J. Zscheischler, B. Steudel,
%      K. Zhang, B. Schölkopf:  Inferring deterministic causal relations.
%      Proceedings of the 26th Annual Conference on Uncertainty in Artificial 
%      Intelligence (UAI-2010).  
%      http://event.cwi.nl/uai2010/papers/UAI2010_0121.pdf
%
% Cause-effect pair challenge modification
% Isabelle Guyon, February 2013:
% UI modified  to provide default parameter values and to
% change the sign of the output for compatibility reasons.

if nargin<3, refMeasure=2; end
if nargin<4, estimator=1; end
    
if nargin <2 || nargin>4
  help igci
  error('Incorrect number of input arguments');
end

f=0;
try
    % ignore complex parts
    x = real(x);
    y = real(y);

    % check input arguments
    [m, dx] = size(x);
    if min(m,dx) ~= 1
      error('Dimensionality of x must be 1');
    end
    % if max(m,dx) < 20
    %   error('Not enough observations in x (must be > 20)');
    % end

    [m, dy] = size(y);
    if min(m,dy) ~= 1
      error('Dimensionality of y must be 1');
    end
    % if max(m,dy) < 20
    %   error('Not enough observations in y (must be > 20)');
    % end

    if length(x) ~= length(y)
        error('Length of x and y must be equal');
    end

    switch refMeasure
      case 1
        % uniform reference measure
        x = (x - min(x)) / (max(x) - min(x));
        y = (y - min(y)) / (max(y) - min(y));
      case 2
        % Gaussian reference measure
        x = (x - mean(x)) ./ std(x);
        y = (y - mean(y)) ./ std(y);
      otherwise
        warning('Warning: unknown reference measure - no scaling applied');
    end       

    switch estimator
      case 1
        % difference of entropies

        [x1,indXs] = sort(x);
        [y1,indYs] = sort(y);

        n1 = length(x1);
        hx = 0.0;
        for i = 1:n1-1
          delta = x1(i+1)-x1(i);
          if delta
            hx = hx + log(abs(delta));
          end
        end
        hx = hx / (n1 - 1) + psi(n1) - psi(1);

        n2 = length(y1);
        hy = 0.0;
        for i = 1:n2-1
          delta = y1(i+1)-y1(i);
          if delta
            hy = hy + log(abs(delta));
          end
        end
        hy = hy / (n2 - 1) + psi(n2) - psi(1);

        f = hy - hx;
      case 2
        % integral-approximation based estimator
        a = 0;
        b = 0;
        [sx,ind1] = sort(x);
        [sy,ind2] = sort(y);

        for i=1:m-1
          X1 = x(ind1(i));  X2 = x(ind1(i+1));
          Y1 = y(ind1(i));  Y2 = y(ind1(i+1));
          if (X2 ~= X1) && (Y2 ~= Y1)   
            a = a + log(abs((Y2 - Y1) / (X2 - X1)));
          end
          X1 = x(ind2(i));  X2 = x(ind2(i+1));
          Y1 = y(ind2(i));  Y2 = y(ind2(i+1));
          if (Y2 ~= Y1) && (X2 ~= X1)
            b = b + log(abs((X2 - X1) / (Y2 - Y1)));
          end
        end

        f = (a - b)/m;
      otherwise 
        error('Unknown estimator');
    end
catch
    warning('igci: execution failed');
end
    
f=-f; % IG

return
