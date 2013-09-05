function testlingam( randseed )
% testlingam - LiNGAM test using completely random parameters
%
% SYNTAX:
% test( randseed );
%
% INPUT:
% randseed    - [optional] random number generator seed 
%
% What?
% Randomly selects testing parameter values, generates data, and
% runs LiNGAM to estimate the parameters. Reports and plots the
% results.
%
% Version: 1.1 (5 July 2005)
%
    
% Makes Octave print stuff immediately. No effect on Matlab.
more off;

% Clears the figures of previous plots
figure(1); clf;
figure(2); clf;
figure(3); clf;


%----------------------------------------------------------------------%
% 1. HANDLE RANDSEED
%----------------------------------------------------------------------%

% If did not define a randseed, choose one randomly (using
% the clock to generate a truly random one).
if ~exist('randseed'),
    rand('seed',sum(100*clock));
    randseed = floor(rand*100000);;
end

% Tell the user which randseed was used, in case one wants
% to repeat the test with that specific randseed.
fprintf('Using randseed: %d\n',randseed);
rand('seed',randseed);
randn('seed',randseed);
    
%----------------------------------------------------------------------%
% 2. GENERATE A MODEL (RANDOMLY SELECT PARAMETERS)
%----------------------------------------------------------------------%

% Number of variables to use: min 2, max 20 (max set arbitrarily)
dims = ceil(rand*19)+1;  
fprintf('Number of dimensions: %d\n',dims);

% Full or sparse connections?
sparse = floor(rand*2);  
if sparse,
    indegree = floor(rand*5)+1;   % how many parents maximally 
    fprintf('Sparse network, max parents = %d\n',indegree);    
else 
    indegree = Inf;               % full connections
    fprintf('Full network.\n');    
end
parminmax = [0.5 1.5]; % [min max] standard deviation owing to parents
errminmax = [0.5 1.5]; % [min max] standard deviation owing to disturbance

% Pause briefly to allow user to inspect chosen parameters
pause(2);

% Create the network with random weights but according to chosen parameters
fprintf('Creating network...');
[B,disturbancestd] = randnetbalanced( dims, indegree, parminmax, errminmax );
c = 2*randn(dims,1); 
fprintf('Done!\n');


%----------------------------------------------------------------------%
% 3. GENERATE DATA FROM THE MODEL
%----------------------------------------------------------------------%

fprintf('Generating data...');

% Nonlinearity exponent, selected to lie in [0.5, 0.8] or [1.2, 2.0].
% (<1 gives subgaussian, >1 gives supergaussian)
q = rand(dims,1)*1.1+0.5;    
ind = find(q>0.8);           
q(ind) = q(ind)+0.4;     

% Number of data vectors
samples = 10000;  

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

% Select a random permutation because we do not assume that we know
% the correct ordering of the variables
p = randperm(dims);

% Permute the rows of the data matrix, to give us the observed data
X = Xorig(p,:);

% Permute the rows and columns of the original generating matrix B 
% so that they correspond to the actual data
Bp = B(p,p);

% Permute the generating disturbance stds so that they correspond to
% the actual data
disturbancestdp = disturbancestd(p);

% Permute the generating constants so that they correspond to
% the actual data
cp = c(p);

fprintf('Done!\n');

%----------------------------------------------------------------------%
% 4. CALL LINGAM TO DO THE ESTIMATION
%----------------------------------------------------------------------%

[Best,stde,ci,causalperm] = lingam(X);

%----------------------------------------------------------------------%
% 5. COMPARE THE ESTIMATED 'B' WITH THE TRUE 'B'
%----------------------------------------------------------------------%

% Slightly different plotting conventions in Matlab and Octave
if exist('OCTAVE_VERSION'),
    plotstyle = 'k*';
else
    plotstyle = 'ko';
end

% First, plot true vs estimated coefficients 
mv = max(max(abs(Bp(:))),max(abs(Best(:)))) * 1.2;;
figure(1); plot(Bp(:),Best(:),plotstyle,[-mv mv],[-mv mv],'r-');
    
% Next, plot true vs estimated error standard deviations 
mv = max(max(abs(disturbancestdp)),max(abs(stde))) * 1.2;;
figure(2); plot(disturbancestdp,stde,plotstyle, ...
		[-mv mv],[-mv mv],'r-');
    
% Finally, plot true vs estimated additive constants 
mv = max(max(abs(cp)),max(abs(ci))) * 1.2;;
figure(3); plot(cp,ci,plotstyle,[-mv mv],[-mv mv],'r-');

% For small dimensions, also display the actual connection matrices
if dims<=8,
   Bp
   Best
end

%----------------------------------------------------------------------%
% 6. TEST TO SEE IF ESTIMATED CAUSAL ORDER IS REALLY CAUSAL
%----------------------------------------------------------------------%

% Note that we cannot simply see if 'p == causalperm', because 
% when the network is sparse there may be several permutations
% of the variables which are all valid causal orders. So we have
% to test whether a strictly lower triangular matrix results
% when the true coefficient matrix is permuted using the 
% estimated causal order.

Bpt = Bp(causalperm,causalperm);
if max(max(abs(Bpt-tril(Bpt,-1))))>1e-8,
    fprintf('Algorithm FAILED in finding a causal order!\n');
    fprintf(['(Note that often the algorithm fails to find a causal\n' ...
	     'order because in the generating B there was some \n' ...
	     'coefficient very close to zero, and with limited data \n' ...
	     'it was treated as zero and hence the order that \n'...
	     'came out was not necessarily right. This is completely \n'...
	     'natural and one should not be upset about this!)\n\n']);
else
    fprintf('Algorithm SUCCEEDED in finding a causal order!\n\n');
end

%----------------------------------------------------------------------%
% 7. GIVE SOME FURTHER STATISTICS ON HOW WELL WE DID
%----------------------------------------------------------------------%

% Recap the number of dimensions and the sparsity of connections
fprintf('Number of dimensions was: %d\n',dims);
if sparse, fprintf('Sparse network, max parents = %d\n\n',indegree);    
else fprintf('Full network.\n\n');    
end

% Number of true connections identified
fprintf('Total correct connections: %d\n', ...
	length(find((Bp(:)~=0) & (Best(:)~=0))));

% Number of correctly identified absence of connections
fprintf('Total correctly absent connections: %d\n', ...
	length(find((Bp(:)==0) & (Best(:)==0)))-dims);

% How many connections were incorrectly thought to be absent
% but which actually were present in the generating model?
% (Note that if very weak connections were pruned this is not
% very significant.)
truepruned = find((Bp(:)~=0) & (Best(:)==0));
maxtruepruned = max(abs(Bp(truepruned)));
ntruepruned = length(truepruned);

if ntruepruned,
    fprintf('Number of true connections pruned: %d [max was %.3f]\n', ...
	    ntruepruned, maxtruepruned );
else
    fprintf('Number of true connections pruned: 0\n');
end
    
% How many spurious connections were added? (i.e. connections
% absent in the generating model but which the algorithm thought
% were present.) Again, if very weak new connections were added
% this is not very bad, but of course if significant connections
% were spuriously included that is quite bad.
superfluous = find((Bp(:)==0) & (Best(:)~=0));
maxsuperfluous = max(abs(Best(superfluous)));
nsuperfluous = length(superfluous);

if nsuperfluous,
    fprintf('Number of superfluous connections: %d [max was %.3f]\n', ...
	    nsuperfluous, maxsuperfluous );
else
    fprintf('Number of superfluous connections: 0\n');
end
    
