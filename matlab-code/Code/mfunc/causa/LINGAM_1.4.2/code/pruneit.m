function [Bpruned, stde, ci] = pruneit(X, k, varargin)
% PRUNEIT Prune weight matrix B.
%
% [Bpruned stde ci] = pruneit(X, k)
%     Prunes and re-estimates the weight matrix using a simple 
%     resampling method. Also re-estimates the standard deviations of error
%     terms and constant terms.
%
% [Bpruned stde ci] = pruneit(X, k, 'method', 'olsboot', 'B', B)
%     Prunes the weight matrix using bootstrapping.
%
% [Bpruned] = pruneit(X, k, 'method', method, 'B', B, 'W', W)
%     Prunes the weight matrix using significances of the edges
%     as given by Wald statistics. There are three variants of this
%     method:
%     'wald'         simply prunes edges that are not significant
%     'bonferroni'   uses Bonferroni correction for the significance
%                    level
%     'hochberg'     applies Hochberg's step up method.
%
% [Bpruned] = pruneit(X, k, 'method', 'modelfit', 'B', B, 'W', W, 'stde', stde)
%     Prunes the weight matrix using significances of the edges
%     as given by Wald statistics. A statistical test of global
%     model fit is used as a stopping criterion.
%
% Input arguments:
%     X        - the original data matrix used in model estimation.
%     k        - the estimated causal ordering of the variables.
%
% Optional input arguments:
%     'method' - selects the pruning method ['resampling'].
%                'resampling' - simple resampling scheme
%                'olsboot'    - bootstrapping
%                'wald'       - Wald statistics
%                'bonferroni' - Wald statistics, Bonferroni correction
%                'hochberg'   - Wald statistics, Hochberg's step up method
%                'modelfit'   - Wald statistics, test of global model fit
%                               as stopping criterion
%     'B'      - the matrix of estimated connection strenghts.
%     'W'      - the demixing matrix W.
%     'stde'   - the standard deviations of the error terms.
%     'alpha'  - the significance level for statistical tests.
%
% Output arguments:
%     Bpruned  - the pruned matrix of connection strenghts.
%     stde     - the re-estimated standard deviations of error terms.
%     ci       - the re-estimated constant terms.
%
% See also ESTIMATE, MODELFIT, LINGAM.

% -----------------------------------------------------------------------------
% Default values for parameters
% -----------------------------------------------------------------------------

method = 'resampling';  % the pruning method
alpha = 0.05;           % the significance level for statistical tests

% 'prunefactor' determines how easily weak connections are pruned
% in the simple resampling based pruning. Zero gives no pruning 
% whatsoever. We use a default of 1, but remember that it is quite arbitrary
% (similar to setting a significance threshold). It should probably
% become an input parameter along with the data, but this is left
% to some future version.
prunefactor = 1;

% -----------------------------------------------------------------------------
% Handle optional input arguments
% -----------------------------------------------------------------------------

for i = 1:2:length(varargin) - 1
  switch varargin{i}
   case 'method'
    method = varargin{i + 1};
   case 'B'
    B = varargin{i + 1};
   case 'W'
    W = varargin{i + 1};
   case 'stde'
    stde = varargin{i + 1};
   case 'alpha'
    alpha = varargin{i + 1};
   otherwise
    error('unknown argument name [%s]', varargin{i});
  end
end

% -----------------------------------------------------------------------------
% Pruning
% -----------------------------------------------------------------------------

fprintf('Pruning the network connections...\n');
[dims ndata] = size(X);

switch method
 case 'resampling'
  % ---------------------------------------------------------------------------
  % Pruning based on resampling: divide the data into several equally
  % sized pieces, calculate B using covariance and QR for each piece
  % (using the estimated causal order), and then use these multiple
  % estimates of B to determine the mean and variance of each element.
  % Prune the network using these.
  
  npieces = 10;
  piecesize = floor(ndata/npieces);
  
  for i=1:npieces,
    
    % Select subset of data, and permute the variables to the causal order
    Xp = X(k,((i-1)*piecesize+1):(i*piecesize));
    
    % Remember to subract out the mean 
    Xpm = mean(Xp,2);
    Xp = Xp - Xpm*ones(1,size(Xp,2));
    
    % Calculate covariance matrix
    C = (Xp*Xp')/size(Xp,2);
    
    % Do QL decomposition on the inverse square root of C
    [Q,L] = tridecomp(C^(-0.5),'ql');
    
    % The estimated disturbance-stds are one over the abs of the diag of L
    newestdisturbancestd = 1./diag(abs(L));
    
    % Normalize rows of L to unit diagonal
    L = L./(diag(L)*ones(1,dims));
    
    % Calculate corresponding B
    Bnewest = eye(dims)-L;

    % Also calculate constants
    cnewest = L*Xpm;

    % Permute back to original variable order
    ik = iperm(k);
    Bnewest = Bnewest(ik, ik);
    newestdisturbancestd = newestdisturbancestd(ik);
    cnewest = cnewest(ik);

    % Save results
    Bpieces(:,:,i) = Bnewest;
    diststdpieces(:,i) = newestdisturbancestd;
    cpieces(:,i) = cnewest;
    
  end

  for i=1:dims,
    for j=1:dims,
      
      themean = mean(Bpieces(i,j,:));
      thestd = std(Bpieces(i,j,:));
      if abs(themean)<prunefactor*thestd,	    
	Bfinal(i,j) = 0;
      else
	Bfinal(i,j) = themean;
      end
      
    end
  end

  diststdfinal = mean(diststdpieces,2);
  cfinal = mean(cpieces,2);

  % Finally, rename all the variables to the way we defined them
  % in the function definition
  
  Bpruned = Bfinal;
  stde = diststdfinal;
  ci = cfinal;

 case 'olsboot',
  % ---------------------------------------------------------------------------
  % Pruning based on bootstrap

  threshold = alpha;
  nboot = 1000;
  Bpruned = olsboot(X, k, threshold, nboot, B);

  
 case 'wald'
  % ---------------------------------------------------------------------------
  % Pruning based on Wald statistics, no correction. If the p-value
  % is larger than a threshold, prune the weight
  
  % Calculate the p-values of Wald statistics.  
  P = calcwald(X, W);

  % Prune the weight matrix
  Bpruned = B;
  Bpruned(P > alpha) = 0;
  
 case 'bonferroni'
  % ---------------------------------------------------------------------------
  % Pruning based on Wald statistics, Bonferroni correction. If the
  % p-value is larger than alpha/#tests, prune the weight
  
  % Calculate the p-values of Wald statistics.  
  P = calcwald(X, W);
  
  % The Bonferroni correction
  ntests = (dims * (dims - 1)) / 2;
  alpha = alpha / ntests;
  
  % Prune the weight matrix
  Bpruned = B;
  Bpruned(P > alpha) = 0;
  
 case 'hochberg' 
  % ---------------------------------------------------------------------------
  % Pruning based on Wald statistics, Hochberg's step up method. 
  % For the ith largest weight, if p-value is larger than alpha/i,
  % prune the weight and continue with i + 1.
  
  % Calculate the p-values of Wald statistics.  
  P = calcwald(X, W);
  P(B == 0) = -1;
  
  % Sort p-values in descending order 
  [pvalues pindices] = sort(P(:)); 
  pvalues = flipud(pvalues); 
  pindices = flipud(pindices);
  
  % Remove p-values that do not correspond to the lower triangular
  % part of the weight matrix
  pvalues(pvalues == -1) = [];
  npvalues = length(pvalues);
  pindices = pindices(1:npvalues);
  
  % Apply the Hochberg's step up method. 
  Bpruned = B;
  for i = 1:npvalues 
    if pvalues(i) > alpha / i 
      Bpruned(pindices(i)) = 0; 
    else 
      break; 
    end 
  end
  
 case 'modelfit'
  % ---------------------------------------------------------------------------
  % Pruning based on Wald statistics, a test for global model
  % fit and a difference test
  
  % Calculate the p-values of Wald statistics.
  P = calcwald(X, W);

  % B(i,j) in the upper triangular and diagonal elemenets have been
  % already set to zero. Then set P(i,j) should be set to a
  % negative value so that they are never accepted.
  P(B == 0) = -1;

  % Sort p-values in descending order 
  [pvalues pindices] = sort(P(:));
  pvalues = flipud(pvalues); 
  pindices = flipud(pindices);
  
  % Prune the weights using model fit as stopping criterion
  fprintf('Processing edges... 0 ');
  Blast = B;
  Bnew = B;
  [chilast dflast pvaluelast] = modelfit(X, Blast, stde, k);
  ntests = sum(pvalues > alpha);
  for i = 1:ntests
    fprintf('%d ', i);
    
    % Prune least significant edge
    Bnew(pindices(i)) = 0;
    [chinew dfnew pvalunew] = modelfit(X, Bnew, stde, k);
    
    % Test if the difference of fit of the two models is significant
    difference = abs(chilast - chinew);
    pvalue = 1 - chi2cdf(difference, 1);
    
    if pvalue > alpha && pvalunew > alpha,
      % Accept the new model and continue pruning
      Blast = Bnew;
      chilast = chinew;
    else
      % Have the pruned edge back
      Bnew = Blast;
      chinew = chilast;
    end
    
  end
  fprintf('\n');
  
  Bpruned = Blast;

end

fprintf('Done!\n');

% -----------------------------------------------------------------------------
function P = calcwald(X, W)
% CALCWALD Calculate the p-values of Wald statistics.

if exist('OCTAVE_VERSION')
    savedLoadPath = LOADPATH;
    LOADPATH = ['fastacovB:', LOADPATH];
else
    addpath('fastacovB');
end

fprintf('Computing Wald statistics...\n');

dims = size(X, 1);
avar = diag(acovB(X, W'));          % asymptotic variance
avar = avar(1:dims ^ 2);            % reshape to correspond W
avar = reshape(avar, dims, dims); 
avar = avar'; 
wald = (W .^ 2) ./ avar;            % Wald statistics 
P = ones(dims) - chi2cdf(wald, 1);  % p-values of Wald statistics 

if exist('OCTAVE_VERSION')
    LOADPATH = savedLoadPath;
else
    rmpath('fastacovB');
end
