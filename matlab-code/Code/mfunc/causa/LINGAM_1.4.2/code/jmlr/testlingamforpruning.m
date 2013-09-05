function [truePos, falsePos, trueNeg, falseNeg] = ...
    testlingamforpruning(nDims, nSamples)
% TESTLINGAMFORPRUNING Test LiNGAM using completely random parameters.
%
% SYNTAX:
% test(nDims, nSamples);
%
% INPUT:
% nDims    - number of dimensions of data.
% nSamples - number of data samples.
%
% What?
% Randomly selects testing parameter values, generates data, and
% runs LiNGAM to estimate the parameters. Counts the numbers of
% true/false positives/nagatives.

% -----------------------------------------------------------------------------
% 1. GENERATE A RANDOM MODEL
% -----------------------------------------------------------------------------

% Full or sparse connections?
sparse = floor(rand * 2);
if sparse
    inDegree = floor(rand * 5) + 1;  % how many parents maximally
else
    inDegree = Inf;                  % full connections
end

parMinMax = [0.5 1.5]; % [min max] standard deviation owing to parents
errMinMax = [0.5 1.5]; % [min max] standard deviation owing to disturbance

% Create the network with random weights but according to chosen parameters
[B disturbanceStd] = randnetbalanced(nDims, inDegree, parMinMax, errMinMax);
c = 2 * randn(nDims, 1); 

%------------------------------------------------------------------------------
% 2. GENERATE DATA FROM THE MODEL
%------------------------------------------------------------------------------

% Nonlinearity exponent, selected to lie in [0.5, 0.8] or [1.2, 2.0].
% (< 1 gives subgaussian, > 1 gives supergaussian)
q = rand(nDims, 1) * 1.1 + 0.5;    
ind = find(q > 0.8);           
q(ind) = q(ind) + 0.4;     

% This generates the disturbance variables, which are mutually 
% independent, and non-gaussian
S = randn(nDims, nSamples);
S = sign(S) .* (abs(S) .^ (q * ones(1, nSamples)));

% This normalizes the disturbance variables to have the 
% appropriate scales
S = S ./ ((sqrt(mean((S') .^ 2)') ./ disturbanceStd) * ones(1, nSamples));

% Now we generate the data one component at a time
Xorig = zeros(nDims, nSamples);
for i = 1:nDims,
    Xorig(i, :) = B(i, :) * Xorig + S(i, :) + c(i);
end

% Select a random permutation because we do not assume that we know
% the correct ordering of the variables
p = randperm(nDims);

% Permute the rows of the data matrix, to give us the observed data
X = Xorig(p, :);

% Permute the rows and columns of the original generating matrix B 
% so that they correspond to the actual data
Bp = B(p, p);

%------------------------------------------------------------------------------
% 3. CALL LINGAM TO DO THE ESTIMATION
%------------------------------------------------------------------------------

[Best stde ci causalperm W] = estimate(X);
Best = prune(X, causalperm, 'method', 'modelfit', 'B', Best, 'W', W, ...
	     'stde', stde);

%------------------------------------------------------------------------------
% 4. COUNT THE NUMBERS OF TRUE/FALSE POSITIVES/NEGATIVES
%------------------------------------------------------------------------------

% Number of true connections identified
truePos = sum((Bp(:) ~= 0) & (Best(:) ~= 0));

% Number of correctly identified absence of connections
nUpperTriangular = nDims * (nDims + 1) / 2;
trueNeg = sum((Bp(:) == 0) & (Best(:) == 0)) - nUpperTriangular;

% How many connections were incorrectly thought to be absent
% but which actually were present in the generating model?
% (Note that if very weak connections were pruned this is not
% very significant.)
falseNeg = sum((Bp(:) ~= 0) & (Best(:) == 0));

% How many spurious connections were added? (i.e. connections
% absent in the generating model but which the algorithm thought
% were present.) Again, if very weak new connections were added
% this is not very bad, but of course if significant connections
% were spuriously included that is quite bad.
falsePos = sum((Bp(:) == 0) & (Best(:) ~= 0));
