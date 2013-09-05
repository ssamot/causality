function testpruning
% TESTPRUNING Test edge pruning.
%
% Count the numbers of correctly identified edges (true positives),
% falsely added edges (false positives), correctly pruned edges (true
% negatives), and falsely pruned edges (false negatives).
%
% This function is used to produce table 1 in our JMLR paper.

randSeed = 1;
nDims = 5;
nSamples = 1000;
nNetworks = 1000;

%----------------------------------------------------------------------%
% 1. HANDLE RANDSEED
%----------------------------------------------------------------------%

% If did not define a randSeed, choose one randomly (using
% the clock to generate a truly random one).
if ~exist('randSeed'),
    rand('seed', sum(100 * clock));
    randSeed = floor(rand * 100000);
end

% Tell the user which randSeed was used, in case one wants
% to repeat the test with that specific randSeed.
fprintf('Using randSeed: %d\n', randSeed);
rand('seed', randSeed);
randn('seed', randSeed);

%----------------------------------------------------------------------%
% 2. DO SIMULATION
%----------------------------------------------------------------------%

truePosVec = zeros(nNetworks, 1);
falsePosVec = zeros(nNetworks, 1);
trueNegVec = zeros(nNetworks, 1);
falseNegVec = zeros(nNetworks, 1);
for i = 1:nNetworks
    [truePos falsePos trueNeg falseNeg] = ...
	testlingamforpruning(nDims, nSamples);
    truePosVec(i) = truePos;
    falsePosVec(i) = falsePos;
    trueNegVec(i) = trueNeg;
    falseNegVec(i) = falseNeg;
end

fprintf('True positives:  %d\n', sum(truePosVec));
fprintf('False negatives: %d\n', sum(falseNegVec));
fprintf('True negatives:  %d\n', sum(trueNegVec));
fprintf('False positives: %d\n', sum(falsePosVec));
