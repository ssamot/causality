function f = pnl(x,y,alpha)
% Performs Post Non-Linear (PNL) causal modeling
% 
% USAGE:
%   f = pnl(x,y,alpha)
% 
% INPUT:
%   x          - m x 1 observations of x
%   y          - m x 1 observations of y
%   alpha      - threshold of statistical significance
% 
% OUTPUT: 
%   f > 0:       the method prefers the causal direction x -> y
%   f < 0:       the method prefers the causal direction y -> x
% 
% EXAMPLE: 
%   x = randn(100,1); y = exp(x); pnl(x,y) > 0

% Wrapper to the PNL function compatible with cause-effect pair challenge interface.
% Mikael Henaff and Isabelle Guyon, February 2013

if nargin<3, alpha=0.05; end
    
if nargin <2 || nargin>3
  help pnl
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
    if dx>m, x=x'; end

    [m, dy] = size(y);
    if min(m,dy) ~= 1
      error('Dimensionality of y must be 1');
    end
    if dy>m, y=y'; end

    if length(x) ~= length(y)
        error('Lengths of x and y must be equal');
    end


    [thresh_1,testS_1,thresh_2,testS_2,fx_1,gy_1,e_1,fx_2,gy_2,e_2] =...
        CauseOrEffect_fun([x, y]', alpha);

    f=testS_1-testS_2;
    
catch
    fprintf(2, 'pnl: execution failed\n');
end

end
