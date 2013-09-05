%res tells you the results:
%    0: both directions
%    1: only correct direction
%    2: no direction
%   -1: only wrong direction inferred.
%
%f_counter, p_counter and n_counter tell you more about the instances of 0
%    and -1.


clear all;
count=0;
level=0.05;

 x_st= 2; y_st=10;
% x_st=10; y_st= 2;
% x_st= 3; y_st=20;
% x_st=20; y_st= 3;
 

f_counter=[];
n_counter=[];
p_counter=[];
        
for i=1:100
    i
    x_rand=[0;sort(rand(x_st-1,1));1];
    n_rand=[0;sort(rand(y_st-1,1));1];
    x_distr=diff(x_rand);
    n_distr=diff(n_rand);
    fct_rand=randi([0,y_st-1],x_st,1);
    while sum(abs(diff(fct_rand)))==0
        fct_rand=randi([0,y_st-1],x_st,1);
    end
    [X Y]=add_noise_cyclic(500, fct_rand, x_distr', n_distr');
%     while p<0.05
%         [X Y p]=add_noise_cyclic(500, fct_rand, x_distr', n_distr');
%     end
    [fct, p, fct_bw, p_bw]=fit_both_dir_discrete(X,1,Y,1,level,0);        
    if (p>level)&&(p_bw>level)
        res(i)=0;
        f_counter=[f_counter;fct_rand'];
        n_counter=[n_counter;n_distr'];
        p_counter=[p_counter;x_distr'];
    elseif (p>level)&&(p_bw<level)
        res(i)=1;
    elseif (p<level)&&(p_bw>level)
        res(i)=-1;
        f_counter=[f_counter;fct_rand'];
        n_counter=[n_counter;n_distr'];
        p_counter=[p_counter;x_distr'];
     elseif (p<level)&&(p_bw<level)
        res(i)=2;
    end
end
        
        
        
