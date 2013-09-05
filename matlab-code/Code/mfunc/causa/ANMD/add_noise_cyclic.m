function [X Y]=add_noise_cyclic(num_samples, fct, X_distr, noise_distr)
%simulates data from a discrete additive noise model.
%
%-X and Y are vectors (each num_samplesx1) containing the samples.
%
%-num_samples: number of samples.
%-X_distr: vector (1 x num_of_states_of_X) from which the input 
%    distribution is sampled (should sum to 1)
%-fct: vector (num_of_states_of_X x 1) of function values (should have the
%    same length as X_distr)
%-noise_distr: vector (1 x num_of_states_of_Y) from which the additive
%    noise is sampled. This vector should the same number of components as
%    Y has states.
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example
%%%%%%%%%
% num_samples=200;
% fct=[0;3;4];
% X_distr=[0.6 0.15 0.25];
% noise_distr=[0.6 0.1 0.1 0.1 0.1];
%
% [X Y]=add_noise_cyclic(num_samples, fct, X_distr, noise_distr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%-LICENSE


num_states_X=length(X_distr);
num_states_Y=length(noise_distr);
X_values=(1:num_states_X)-1;
noise_values=0:1:(num_states_Y-1);

tmp=0;
for i=1:length(noise_distr)
    tmp=tmp+noise_distr(i);
    noise_cdf(i)=tmp;
end
tmp=0;
for i=1:length(X_distr)
    tmp=tmp+X_distr(i);
    X_cdf(i)=tmp;
end
clear X Y;
%X=randi(num_states_X,num_samples,1)-1;
X=rand(num_samples,1);
for i=1:num_samples
    X(i)=X_values(sum(X(i)>X_cdf)+1);
end

eps=rand(num_samples,1);
for i=1:num_samples
    eps(i)=noise_values(sum(eps(i)>noise_cdf)+1);
end
Y=mod(fct(X+1)+eps,num_states_Y);
%p=chi_sq_quant(X,eps,num_states_X,num_states_Y);
%p=g_quantile(X,eps,num_states_X,num_states_Y)


