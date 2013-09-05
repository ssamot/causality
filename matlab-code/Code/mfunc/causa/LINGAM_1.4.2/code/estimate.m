function [B, stde, ci, k, Wout] = estimate(X)
% ESTIMATE Estimate LiNGAM model from data.
%
% Estimates a LiNGAM model from data. The returned weight matrix B
% is strictly lower triangular, but the weights are not pruned. To
% prune the matrix, call PRUNE.
%
% SYNTAX:
% [B stde ci k] = estimate(X);
% [B stde ci k W] = estimate(X);
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
% OPTIONAL OUTPUT:
% W     - The demixing matrix of ICs, in estimated row ordering.
%
% (Note that B, stde, ci, and optionally W are all ordered
%  according to the same variable ordering as X.)
%
% See also PRUNE, MODELFIT, LINGAM.

% For verbose mode, set to 'on'
verbose='off';

if strcmp(verbose, 'on')
    fp=2;
else
    fp=0;
end

LPATH=get_path('LINGAM_1.4.2/lib');
if ~isempty(LPATH)
    LPATH=[LPATH(1:length(LPATH)-3) 'FastICA_23'];
else
    LPATH='../FastICA_23';
end


% For Octave compatibility
if exist('OCTAVE_VERSION'),
    savedLoadPath = LOADPATH;
    LOADPATH = ['../FastICA_21_octave:', LOADPATH];
else
    addpath(LPATH);
end

% Call the FastICA algorithm
[icasig, A, W] = fastica( X, 'approach', 'symm', 'g', 'tanh', ...
			  'epsilon', 1e-14, 'displayMode', 'off', 'verbose', verbose);    

if exist('OCTAVE_VERSION'),
    LOADPATH = savedLoadPath;
else
    rmpath(LPATH);
end

% [Here, we really should perform some tests to see if the 'icasig' 
%  really are independent. If they are not very independent, we should
%  issue a warning. This is not yet implemented.]

% Try to permute the rows of W so that sum(1./abs(diag(W))) is minimized
dprintf(fp, 'Performing row permutation...\n');
dims = size(X,1);
if dims<=8,  
    dprintf(fp, '(Small dimensionality, using brute-force method.)\n');
    [Wp,rowp] = nzdiagbruteforce( W );
else
    dprintf(fp, '(Using the Hungarian algorithm.)\n');
    [Wp,rowp] = nzdiaghungarian( W );
end
dprintf(fp, 'Done!\n');

% Set Wout before scaling the Wp.
if nargout == 5
  Wout = Wp;
end

% Divide each row of Wp by the diagonal element
estdisturbancestd = 1./diag(abs(Wp));
Wp = Wp./(diag(Wp)*ones(1,dims));

% Compute corresponding B
Best = eye(dims)-Wp;

% Estimate the constants c
cest = Wp*mean(X,2);


% Next, identically permute the rows and columns of B so as to get an
% approximately strictly lower triangular matrix
dprintf(fp, 'Performing permutation for causal order...\n');

if dims<=8,  
    dprintf(fp, '(Small dimensionality, using brute-force method.)\n');
    [Bestcausal,causalperm] = sltbruteforce( Best );
else
    dprintf(fp, '(Using pruning algorithm.)\n');
    [Bestcausal,causalperm] = sltprune( Best );
end
dprintf(fp, 'Done!\n');

% Here, we report how lower triangular the result was, and in 
% particular we issue a warning if it was not so good!
percentinupper = sltscore(Bestcausal)/sum(sum(Bestcausal.^2));
if percentinupper>0.2,
    dprintf(fp, 'WARNING: Causal B not really triangular at all!!\n');
elseif percentinupper>0.05,
    dprintf(fp, 'WARNING: Causal B only somewhat triangular!\n');
else
    dprintf(fp, 'Causal B nicely triangular. No problems to report here.\n');
end    

% Set the upper triangular to zero
Bestcausal = tril(Bestcausal, -1);

% Finally, permute 'Bestcausal' back to the original variable
% ordering and rename all the variables to the way we defined them
% in the function definition

icausal = iperm(causalperm);
B = Bestcausal(icausal, icausal);
stde = estdisturbancestd;
ci = cest;
k = causalperm;
