function [Bopt,optperm] = sltbruteforce( B )

% Finds the best identical row and column permutation in terms of getting
% approximately strictly lower triangular matrix
    
%--------------------------------------------------------------------------
% Try all permutations, find best solution
%--------------------------------------------------------------------------

n = size(B,1);

bestval = Inf;
besti = 0;
allperms = perms(1:n);
nperms = size(allperms,1);

for i=1:nperms,
    Btilde = B(allperms(i,:),allperms(i,:));
    c = sltscore(Btilde);
    if c<bestval,
	bestBtilde = Btilde;
	bestval = c;
	besti = i;
    end
end

Bopt = bestBtilde;
optperm = allperms(besti,:);

