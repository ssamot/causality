function [f, B,stde,ci,k] = lingam( A, B )
% lingam - perform the LiNGAM analysis
% Modified version for the cause-effect pair challenge
% See lingam_orig for the original version.
%
% [f, B,stde,ci,k] = lingam( A, B );
%
% INPUT:
% A and B: column vectors of two variables.
%
% OUTPUT:
% f=abs(B(2,1)-abs(1,2));
% if A->B
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
% See also ESTIMATE, PRUNEIT, MODELFIT.

% Cause-effect pair challenge wrapper 
% Mikael Henaff and Isabelle Guyon, February 2013
% Note IG: prune changed to prunit to avoid name clash with other code...

f=0;
%for verbose mode, set verbose='on' in the call of fastica in estimate.m
try
    X=[A, B]';
    
    [B stde ci k] = estimate(X);
    f=abs(B(2,1))-abs(B(1,2));

    %[B stde ci] = pruneit(X, k);
catch
    fprintf(2, 'lingam: execution failed\n');
end
