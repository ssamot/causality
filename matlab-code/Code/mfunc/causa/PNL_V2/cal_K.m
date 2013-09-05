function K = cal_K(y,xx)
% calculates K: K(j) = -2*\sum_i[ E{xi*yj}*xi/E{yj^2} - E{xi*yj}^2/E{yj^2}^2 * yj]

[N,T] = size(y);
[M,T] = size(xx);

for j = 1:N
    var_y = y(j,:)*y(j,:)'/T;
    Multi = mean((xx.* (ones(M,1)*y(j,:)))');
    Multi = Multi';
    K1 = sum( Multi * ones(1,T) .*xx )/var_y;
    
    K2 = sum(Multi.^2) /var_y^2 * y(j,:) ;
    K(j,:) = -2*(K1 - K2);
end