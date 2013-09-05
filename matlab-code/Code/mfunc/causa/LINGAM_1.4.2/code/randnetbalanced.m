function [B,errstd] = randnetbalanced( dims, indegree, parminmax, errminmax )
% randnetbalanced - create a more balanced random network
%
% INPUT:
%
% dims       - number of variables
% indegree   - number of parents of each node (Inf = fully connected)
% parminmax  - [min max] standard deviation owing to parents 
% errminmax  - [min max] standard deviation owing to error variable
%
% OUTPUT:
% 
% B      - the strictly lower triangular network matrix
% errstd - the vector of error (disturbance) standard deviations
%
    
% Number of samples used to estimate covariance structure
samples = 10000; 
    
% First, generate errstd
errstd = rand(dims,1)*(errminmax(2)-errminmax(1)) + errminmax(1);

% Initializations
X = [];
B = zeros(dims,dims);

% Go trough each node in turn:
for i=1:dims,
   
    % If 'indegree' is finite, randomly pick that many parents,
    % else, all previous variables are parents
    if ~isinf(indegree),
	if i<=indegree,
	    par = 1:(i-1);
	else
	    par = randperm((i-1));
	    par = par(1:indegree);
	end
    else
	par = 1:(i-1);
    end
    
    % If node has parents, do the following
    if ~isempty(par),
	
	% Randomly pick weights
	w = randn(length(par),1);
	wfull = zeros(i-1,1); wfull(par) = w;

	% Calculate contribution of parents
	X(i,:) = wfull'*X;
		
	% Randomly select a 'parents std' 
	parstd = rand*(parminmax(2)-parminmax(1)) + parminmax(1);
	
	% Scale w so that the combination of parents has 'parstd' std
	scaling = parstd/sqrt(mean(X(i,:).^2));
	w = w*scaling;

	% Recalculate contribution of parents
	wfull = zeros(i-1,1); wfull(par) = w;	
	X(i,:) = wfull'*X(1:(i-1),:);
	
	% Fill in B
	B(i,par) = w';
	
    % if node has no parents
    else
	
	% Increase errstd to get it to roughly same variance
	parstd = rand*(parminmax(2)-parminmax(1)) + parminmax(1);
	errstd(i) = sqrt(errstd(i)^2 + parstd^2);
	
	% Set data matrix to empty
	X(i,:) = zeros(1,samples);
	
    end
	
    % Update data matrix
    X(i,:) = X(i,:) + randn(1,samples)*errstd(i);
    
end
    
