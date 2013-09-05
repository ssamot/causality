function [chi, df, pvalue] = modelfit(X, B, stde, k)
% MODELFIT A test statistic for global model fit.
%
% Input arguments:
%   X      - the data.
%   B      - the weight matrix.
%   stde   - the standard deviations of error terms.
%   k      - the estimated causal order.
%
% Output arguments:
%   chi    - the value of the test statistic.
%   df     - degrees of freedom.
%   pvalue - the p-value of the test statistic.
%
% See also ESTIMATE, PRUNE, LINGAM.

if exist('OCTAVE_VERSION')
    savedLoadPath = LOADPATH;
    LOADPATH = ['modelfit:', LOADPATH];
else
    addpath('modelfit');
end

vare = stde .^ 2;
[chi df pvalue] = secondmodelfit(X(k, :), B(k, k), diag(vare(k))); 

if exist('OCTAVE_VERSION')
    LOADPATH = savedLoadPath;
else
    rmpath('modelfit');
end
