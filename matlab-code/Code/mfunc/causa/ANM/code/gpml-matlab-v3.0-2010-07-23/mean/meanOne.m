function A = meanOne(hyp, x, i)

% One mean function. The mean function does not have any parameters.
%
% m(x) = 1
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-07-15.
%
% See also MEANFUNCTIONS.M.

if nargin<2, A = '0'; return; end             % report number of hyperparameters 
A = ones(size(x,1),1);                                     % derivative and mean
