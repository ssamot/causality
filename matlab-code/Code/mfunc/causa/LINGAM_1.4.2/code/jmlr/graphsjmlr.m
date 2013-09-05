function graphsjmlr(randseed, dims)
% GRAPHSJMLR Plot graphs for JMLR paper.
%
% Plots the generating model and the estimated model for single
% lingam estimation. Network is pruned using model fit based
% pruning.
%
% For figure 3 in JMLR: randseed = 1, dims = 6

% The following is mostly copied from 'plots'

% Set the seed of random number generators
if nargin == 0
  randseed = 0;
end
fprintf('Using randseed: %d\n',randseed);
rand('seed',randseed);
randn('seed',randseed);

% --- Network and data generation ---

if nargin < 2
  dims = 6;
end
samples = 10000;

% Sparse connections
indegree = floor(rand*3)+1;

% [min max] standard deviation owing to parents
parminmax = [0.5 1.5]; 

% [min max] standard deviation owing to disturbance
errminmax = [0.5 1.5]; 

% Create the network
[B,disturbancestd] = ...
    randnetbalanced( dims, indegree, parminmax, errminmax );

% constants, giving non-zero means
c = 2*randn(dims,1);  

% nonlinearity exponent, in [0.5, 0.8] or [1.2, 2.0].
q = rand(dims,1)*1.1+0.5;    
ind = find(q>0.8);           
q(ind) = q(ind)+0.4;     

% This generates the disturbance variables, which are mutually 
% independent, and non-gaussian
S = randn(dims,samples);
S = sign(S).*(abs(S).^(q*ones(1,samples)));

% This normalizes the disturbance variables to have the 
% appropriate scales
S = S./((sqrt(mean((S').^2)')./disturbancestd)*ones(1,samples));

% Now we generate the data one component at a time
Xorig = zeros(dims,samples);
for i=1:dims,
  Xorig(i,:) = B(i,:)*Xorig + S(i,:) + c(i);
end

% Select a random permutation because we do not assume that 
% we know the correct ordering of the variables
p = randperm(dims);
	    
% Permute the rows of the data matrix, to give us the 
% observed data
X = Xorig(p,:);

% Permute the rows and columns of the original generating 
% matrix B so that they correspond to the actual data
Bp = B(p,p);
	    
% Permute the generating disturbance stds so that they 
% correspond to the actual data
disturbancestdp = disturbancestd(p);
	
% Permute the generating constants so that they correspond to
% the actual data
cp = c(p);

% --- Call LiNGAM to do the actual estimation ---

[Best stde ci k W] = estimate(X);
Best = prune(X, k, 'method', 'modelfit', 'B', Best, 'W', W, 'stde', stde);

plotmodel(B, 1:dims, 'target', 'psviewer');
ip = iperm(p);
Best = Best(ip, ip);
plotmodel(Best, 1:dims, 'target', 'psviewer');
