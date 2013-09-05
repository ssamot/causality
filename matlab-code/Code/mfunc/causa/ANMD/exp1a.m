%res tells you the results:
%    0: both directions
%    1: only correct direction
%    2: no direction
%   -1: only wrong direction inferred.
%
%example_rev tells you more about the instances of 0 and
%
%example_rev2 tells you more about the instances of -1.




clear all;
counter=0;
counter2=0;
level=0.05;
num_samples=2000;

for i=1:1000
    i
    alpha=2*(rand(7,1)-0.5*ones(7,1));
    %fct_kind='fct';
    %fct=@(x) round(alpha(1)+alpha(2)*x+alpha(3)*x.^2+alpha(4)*x.^3+alpha(5)*x.^4+alpha(6)*x.^5+alpha(7)*x.^6);
    fct_kind='vector';
    fct=round(randi(15,2000,1)-8*ones(2000,1));
    mod(1)=randi(7);
    mod(2)=1;
    switch mod(1)
        case 1
            x_rand=[0;sort(rand(6-1,1));1];
            pars.p_X=diff(x_rand);
            pars.X_values=(1:6)';
            X_distr='custom';
        case 2
            x_rand=[0;sort(rand(4-1,1));1];
            pars.p_X=diff(x_rand);
            pars.X_values=(1:4)';
            X_distr='custom';
        case 3 %%bino-binornd
            pars.N=randi(40);
            pars.p=(0.8*rand+0.1);
            X_distr='bino';
        case 4 %%geo-geornd
            pars.p=(0.8*rand+0.1);
            X_distr='geo';
        case 5 %%hypergeo-hygernd
            pars.M=randi(40);
            pars.K=randi(pars.M);
            pars.N=randi(pars.K);
            X_distr='hypergeo';
        case 6 %%negbin-nbinrnd
            pars.R=randi(20);
            pars.P=(0.8*rand+0.1);
            X_distr='negbin';
        case 7 %%poisson-poissrnd
            pars.lambda=10*rand;
            X_distr='poisson';
    end
    switch mod(2)
        case 1
            tmp=randi(5);
            length=2*tmp+1;
            n_rand=[0;sort(rand(length-1,1));1];
            pars2.p_n=diff(n_rand)';
            pars2.n_values=((-tmp):tmp)';
            n_distr='custom';
        case 2
            n_rand=[0;sort(rand(5-1,1));1];
            pars2.p_n=diff(n_rand)';
            pars2.n_values=(-2:2)';
            n_distr='custom';
        case 3 %%bino-binornd
            pars2.N=randi(100);
            pars2.p=rand;
            n_distr='bino';
        case 4 %%geo-geornd
            pars2.p=(0.8*rand+0.1);
            n_distr='geo';
        case 5 %%hypergeo-hygernd
            pars2.M=randi(200);
            pars2.K=randi(pars2.M);
            pars2.N=randi(pars2.M);
            n_distr='hypergeo';
        case 6 %%negbin-nbinrnd
            pars2.R=randi(20);
            pars2.P=(0.8*rand+0.1);
            n_distr='negbin';
        case 7 %%poisson-poissrnd
            pars2.lambda=10*rand;
            n_distr='poisson';
    end       
    [X Y]=add_noise(num_samples, fct, X_distr, pars, n_distr, pars2, fct_kind);
    speicherX{i}=X;
    speicherY{i}=Y;
    
    [fct_fw, p, fct_bw, p_bw]=fit_both_dir_discrete(X,0,Y,0,level,0);        
    if (p>level)&&(p_bw>level)
        res(i)=0;
        counter=counter+1;
        example_rev.number{counter}=i;
        example_rev.mod{counter}=mod(1);
        example_rev.X{counter}=unique(X);
        example_rev.fct{counter}=fct(unique(X));
        example_rev.n_distr{counter}=pars2.p_n;
            uni_X=unique(X);
            for j=1:size(uni_X,1)
                x_distr(j)=sum(X==uni_X(j))/num_samples;
            end    
        example_rev.x_distr{counter}=x_distr;
        clear x_distr;
    elseif (p>level)&&(p_bw<level)
        res(i)=1;
    elseif (p<level)&&(p_bw>level)
        res(i)=-1;
        counter2=counter2+1;
        example_rev2.number{counter2}=i;
        example_rev2.mod{counter2}=mod(1);
        example_rev2.X{counter2}=unique(X);
        example_rev2.fct{counter2}=fct(unique(X));
        example_rev2.n_distr{counter2}=pars2.p_n;
            uni_X=unique(X);
            for j=1:size(uni_X,1)
                x_distr(j)=sum(X==uni_X(j))/num_samples;
            end    
        example_rev2.x_distr{counter2}=x_distr;
        clear x_distr;
     elseif (p<level)&&(p_bw<level)
        res(i)=2;
    end
end

        
        
        
