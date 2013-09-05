function plotsjmlr(method)
% PLOTSJMLR Produces scatterplots for our JMLR paper.
%
% Similar to plots.m, but has an option to use different pruning
% methods. The scatterplots in Figure 2 are produced with call
% 'plotsjmlr' without input arguments.


if nargin == 0
    method = 'nopruning';
end

% Makes Octave print stuff immediately. No effect on Matlab.
more off;

% Warn user that plots will go on top of each other in Octave    
if exist('OCTAVE_VERSION'),
    fprintf(['Note that this function uses subplot, which does not\n' ...
            'seem to work with Octave, so all the subplots are\n' ...
            'plotted on top of each other. Sorry! (Press any key\n' ...
            'to continue...)\n']);
    pause;
end

% Set the randseed to the same each time
randseed = 0;
fprintf('Using randseed: %d\n',randseed);
rand('seed',randseed);
randn('seed',randseed);

% Clear figure
figure(1);
clf; drawnow;

% How many tests to run for each dimensionality and sample size?
ntests = 5;    

% Iterate through different data dimensionalities
itotal = 0;
idims = 0;
testdims = [3 5 10 20 100];

for dims = testdims,
    
    idims = idims+1;
    
    % Iterate through different dataset sizes
    isamples = 0;
    testsamples = [200 1000 5000];
    for samples = testsamples,
        
        isamples = isamples+1;
        itotal = itotal+1;
        
        % --- Initialize variables to store data to be plotted ---
        
        scatterp = [];
        
        % Do a number of tests with these parameters
        for itests = 1:ntests,
            
            % --- Network and data generation ---
            
            % Randomly select sparse/full connections
            sparse = floor(rand*2);  
            if sparse, indegree = floor(rand*3)+1;
            else indegree = Inf;
            end
            
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
            switch method
                case 'resampling'
                    [Best stde ci] = prune(X, k);
                case {'wald', 'bonferroni', 'hochberg'}
                    Best = prune(X, k, 'method', method, 'B', Best, 'W', W);
                case 'modelfit'
                    Best = prune(X, k, 'method', 'modelfit', ...
                        'B', Best, 'W', W, 'stde', stde);
            end
            
            % --- Collect the data for plotting ---
            
            % Gather everything for one scatter plot
            if dims < 20,
                scatterp = [scatterp; [Bp(:) Best(:)]];
            else            
                % Take a random selection of the points so that
                % they sum up to 1000.
                nselection = floor(1000/ntests);
		indexperm = randperm(dims * dims);
                selection = indexperm(1:nselection);
		
		orig = Bp(:);
		est = Best(:);
                scatterp = [scatterp; [orig(selection) est(selection)]];
            end
        end
        
        % Create scatterplot for this combination of dims/samples
        figure(1);
        subplot(length(testdims),length(testsamples),itotal);
        mv = 3;
        figure(1); plot(scatterp(:,1),scatterp(:,2),'ko', ...
            [-mv mv],[-mv mv],'r-');
        axis([-mv mv -mv mv]);
        drawnow;
        
    end
    
end
