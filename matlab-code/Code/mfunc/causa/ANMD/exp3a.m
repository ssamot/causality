%iter_mean and
%iter_sd give the number of functions checked by our method (mean and standard deviation).
%
%The other two numbers are theoretical values that can be computed easily.
%

counter=1;
for i=3:2:20
    pars.p_X=ones(1,i)*1/i;
    pars.X_values=[(-(i-1)/2):1:((i-1)/2)]';
 %%%%
 %N1, left picture
 %%%%
    %pars2.p_n=[0.05 0.3 0.3 0.3 0.05];
    %pars2.n_values=[-2;-1;0;1;2];
 %%%%
 %N2, right picture
 %%%%
    pars2.p_n=[0.05 0.18 0.18 0.18 0.18 0.18 0.05];
    pars2.n_values=[-3;-2;-1;0;1;2;3];
    for j=1:100
        [X Y p]=add_noise_exp3a(2000,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
        while p<0.05
            [X Y p]=add_noise_exp3a(2000,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
        end
        [fct_fw p_val_fw iter_tmp(j) num_x_val_tmp(j)]=fit_discrete_exp3a(X,Y,0.048,0,0);
        check(j)=length(unique(fct_fw-round(0.5*(pars.X_values).^2)));
    end
    iter_mean(counter)=mean(iter_tmp*num_x_val_tmp(1));
    iter_sd(counter)=sqrt(var(iter_tmp*num_x_val_tmp(1)));
    [iter_tmp;check]
    [iter_mean(counter) iter_sd(counter)]
    checker{counter}=unique(check);
    counter=counter+1;
%    pause
end



