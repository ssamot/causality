function [ tstat, pval ] = correl( A, B )
%[ tstat, pval ] = correl( A, B )
%   Computes the absolute value of the Pearson correlation coefficient 
% and the corresponding pvalue

[r, p]=corrcoef(A, B);
tstat=abs(r(1,2));
pval=p(1,2);

end

