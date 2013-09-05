function [Wopt,rowp] = nzdiagbruteforce( W )

%--------------------------------------------------------------------------
% Try all row permutations, find best solution
%--------------------------------------------------------------------------

n = size(W,1);

bestval = Inf;
besti = 0;
if exist('OCTAVE_VERSION')
    allperms = permsOctave(n);
else
    allperms = perms(1:n);
end
nperms = size(allperms,1);

for i=1:nperms,
    Pr = eye(n); Pr = Pr(:,allperms(i,:));
    Wtilde = Pr*W;
    c = nzdiagscore(Wtilde);
    if c<bestval,
	bestWtilde = Wtilde;
	bestval = c;
	besti = i;
    end
end

Wopt = bestWtilde;
rowp = allperms(besti,:);
rowp = iperm(rowp);
