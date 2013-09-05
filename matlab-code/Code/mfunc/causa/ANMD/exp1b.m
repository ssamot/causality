%res contains the results, the details of the reversible cases are stored
%in f_counter, n_counter and p_counter


clear all;
count=0;
level=0.05;
x_states=[3 3 5];
y_states=[3 5 3];

for mod=1:3
    f_counter{mod}=[];
    p_counter{mod}=[];
    n_counter{mod}=[];
    x_st=x_states(mod);
    y_st=y_states(mod);
    for i=1:1000
        i
        x_rand=[0;sort(rand(x_st-1,1));1];
        n_rand=[0;sort(rand(y_st-1,1));1];
        x_distr=diff(x_rand);
        n_distr=diff(n_rand);
        fct_rand=randi([0,y_st-1],x_st,1);
        while sum(abs(diff(fct_rand)))==0
            fct_rand=randi([0,y_st-1],x_st,1);
        end
        [X Y]=add_noise_cyclic(10000, fct_rand, x_distr', n_distr');
        [fct, p, fct_bw, p_bw]=fit_both_dir_discrete(X,1,Y,1,level,0);        
        if (p>level)&&(p_bw>level)
            res(mod,i)=0;
            no_fit(mod,i)=1;
            f_counter{mod}=[f_counter{mod};fct_rand'];
            n_counter{mod}=[n_counter{mod};n_distr'];
            p_counter{mod}=[p_counter{mod};x_distr'];
        elseif (p>level)&&(p_bw<level)
            res(mod,i)=1;
        elseif (p<level)&&(p_bw>level)
            res(mod,i)=-1;
            f_counter{mod}=[f_counter{mod};fct_rand'];
            n_counter{mod}=[n_counter{mod};n_distr'];
            p_counter{mod}=[p_counter{mod};x_distr'];
         elseif (p<level)&&(p_bw<level)
            res(mod,i)=0;
            no_fit(mod,i)=-1;
        end
    end
end
        
        
        
