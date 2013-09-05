function findexample(randSeed, nDims)
% FINDEXAMPLE Find an example graph for JMLR paper.
%
% This function is used to produce figure 4 in our JMLR paper.
% The paper's plots are from 3rd iteration (with default
% parameters), running the function in Matlab.


% Set the seed of random number generators
if nargin == 0
    randSeed = 0;
end
fprintf('Using randSeed: %d\n', randSeed);
rand('seed', randSeed);
randn('seed', randSeed);

if nargin < 2
    nDims = 7;
end
nSamples = 10000;

nIteration = 1;
while true
    % --- Network and data generation ---
    
    % Sparse connections
    indegree = floor(rand*3)+1;
  
    % [min max] standard deviation owing to parents
    parminmax = [0.5 1.5]; 
    
    % [min max] standard deviation owing to disturbance
    errminmax = [0.5 1.5]; 
    
    % Create the network
    [B,disturbancestd] = ...
	randnetbalanced( nDims, indegree, parminmax, errminmax );
  
    % constants, giving non-zero means
    c = 2*randn(nDims,1);  
    
    % nonlinearity exponent, in [0.5, 0.8] or [1.2, 2.0].
    q = rand(nDims,1)*1.1+0.5;    
    ind = find(q>0.8);           
    q(ind) = q(ind)+0.4;     
    
    % This generates the disturbance variables, which are mutually 
    % independent, and non-gaussian
    S = randn(nDims,nSamples);
    S = sign(S).*(abs(S).^(q*ones(1,nSamples)));
    
    % This normalizes the disturbance variables to have the 
    % appropriate scales
    S = S./((sqrt(mean((S').^2)')./disturbancestd)*ones(1,nSamples));
    
    % Now we generate the data one component at a time
    Xorig = zeros(nDims,nSamples);
    for i=1:nDims,
	Xorig(i,:) = B(i,:)*Xorig + S(i,:) + c(i);
    end
  
    % Select a random permutation because we do not assume that 
    % we know the correct ordering of the variables
    p = randperm(nDims);
    
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

    % Plot the generating and the estimated model
    plotmodel(B, 1:nDims, 'target', 'psviewer');
    ip = iperm(p);
    Best = Best(ip, ip);
    plotmodel(Best, 1:nDims, 'target', 'psviewer');
    
    % Ask if the user wants to see more graphs    
    fprintf('nIteration = %d\n', nIteration);
    reply = input('Quit? y/n [n]: ', 's');
    if strcmp(reply, 'y')
	break;
    end
    
    nIteration = nIteration + 1;    
end
