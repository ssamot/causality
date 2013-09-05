function p = slttestperm( B )
% slttestperm - tests if we can permute B to strict lower triangularity
%
% If we can, then we return the permutation in p, otherwise p=0.
%
    
% Dimensionality of the problem
n = size(B,1);    
    
% This will hold the permutation
p = [];

% Remaining nodes
remnodes = 1:n;

% Remaining B, take absolute value now for convenience
Brem = abs(B);

% Select nodes one-by-one
for i=1:n,
    
    % Find the row with all zeros
    therow = find(sum(Brem,2)<1e-12);
    
    % If empty, return 0
    if isempty(therow),
	p = 0;
	return;
    end
    
    % If more than one, arbitrarily select the first 
    therow = therow(1);
    
    % If we made it to the end, then great!
    if i==n,
	p = [p remnodes];
	return
    end
    
    % Take out that row and that column
    inds = find((1:(n-i+1)) ~= therow);
    Brem = Brem(inds,inds);

    % Update remaining nodes
    p = [p remnodes(therow)];
    remnodes = remnodes(inds);
    
end

