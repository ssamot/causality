function [B,stde,ci,k] = lingam( X )
% lingam - perform the LiNGAM analysis
%
% This function is provided for compatibility with earlier versions
% of LiNGAM. Consider using ESTIMATE and PRUNE instead.
%
% SYNTAX:
% [B,stde,ci,k] = lingam( X );
%
% INPUT:
% X     - Data matrix: each row is an observed variable, each
%         column one observed sample. The number of columns should
%         be far larger than the number of rows.
%
% OUTPUT:
% B     - Matrix of estimated connection strenghts
% stde  - Standard deviations of disturbance variables
% ci    - Constants
% k     - An estimated causal ordering
%
% (Note that B, stde, and ci are all ordered according to the same
%  variable ordering as X.)
%
% Version: 1.3 (22 Feb 2006)
%
% See also ESTIMATE, PRUNE, MODELFIT.
    
[B stde ci k] = estimate(X);
[B stde ci] = prune(X, k);
