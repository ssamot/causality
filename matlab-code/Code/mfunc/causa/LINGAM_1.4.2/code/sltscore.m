function s = sltscore( B )
% sltscore - strictly lower triangular score
    
D = tril(B,-1)-B;
s = sum(sum(D.^2));

