function [X Y]=add_noise(num_samples, fct, X_distr, pars_X, n_distr, pars_n, fct_kind)
%simulates data from a discrete additive noise model.
%
%-X and Y are vectors (each num_samplesx1) containing the samples.
%
%-num_samples: number of samples.
%
%-n_distr can be
%    'bino' for binornd
%    'geo' for geornd
%    'hypergeo' for hygernd
%    'multin' for mnrnd
%    'negbin' for nbinrnd
%    'poisson' for poissrnd
%    'custom' for a user-specific noise distribution. Then 
%        pars_n.p_n: a vector of probabilities (should sum to one)
%        pars_n.n_values: a vector of values of n
%-otherwise pars_n contains the parameters for the distribution.
%
%
%
%
% CASE 1:
%-X_distr can be 'custom'. Then
%-pars_X contains
%     pars_X.p_X: a vector of probabilities (should sum to one)
%     pars_X.X_values: a vector of values of X
%-fct_kind should be 'vector',
%-fct is a vector (kx1) containing the function values on pars_X.X_values
%     (thus they should have the same length).
%
%
%CASE 2:
%-X_distr can be
%    'bino' for binornd
%    'geo' for geornd
%    'hypergeo' for hygernd
%    'multin' for mnrnd
%    'negbin' for nbinrnd
%    'poisson' for poissrnd. Then
%-pars_X contains the parameters for the distribution.
%-fct_kind should be 'fct',
%-fct should be a function (e.g. @(x) round(0.5*x.^2))
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example
%%%%%%%%%
% num_samples=200;
% fct_kind='vector';
% fct=[0;3;4];
% X_distr='custom';
% pars_X.p_X=[0.6 0.15 0.25];
% pars_X.X_values=[-3;1;2];
% n_distr='custom';
% pars_n.p_n=[0.1 0.3 0.3 0.2 0.1];
% pars_n.n_values=[-2;-1;0;1;2];
%
% [X Y]=add_noise(num_samples, fct, X_distr, pars_X, n_distr, pars_n, fct_kind);
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
    
switch lower(n_distr)
    case 'custom'
        tmp=0;
        for i=1:length(pars_n.p_n)
            tmp=tmp+pars_n.p_n(i);
            noise_cdf(i)=tmp;
        end
        eps=rand(num_samples,1);
        for i=1:num_samples
            eps(i)=sum(eps(i)>noise_cdf)+1;
        end
        eps=pars_n.n_values(eps);
    case 'bino'
        eps=binornd(pars_n.N,pars_n.p,num_samples,1);
    case 'geo'
        eps=geornd(pars_n.p,num_samples,1);
    case 'hypergeo'
        eps= hygernd(pars_n.M,pars_n.K,pars_n.N,num_samples,1);
    case 'negbin'
        eps=nbinrnd(pars_n.R,pars_n.P,num_samples,1);
    case 'poisson'
        eps=poissrnd(pars_n.lambda,num_samples,1);
end

switch lower(X_distr)
    case 'custom'
        tmp=0;
        for i=1:length(pars_X.p_X)
            tmp=tmp+pars_X.p_X(i);
            X_cdf(i)=tmp;
        end
        X=rand(num_samples,1);
        for i=1:num_samples
            X(i)=sum(X(i)>X_cdf)+1;
        end
        switch lower(fct_kind)
            case 'fct'
                X=pars_X.X_values(X);
                Y=fct(X)+eps;
            case 'vector'
                Y=fct(X)+eps;
                X=pars_X.X_values(X);
            end
    case 'bino'
        X=binornd(pars_X.N,pars_X.p,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'geo'
        X=geornd(pars_X.p,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'hypergeo'
        X= hygernd(pars_X.M,pars_X.K,pars_X.N,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'negbin'
        X= nbinrnd(pars_X.R,pars_X.P,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'poisson'
        X= poissrnd(pars_X.lambda,num_samples,1)+1;
        Y=fct(X)+eps;
end

% chi_sq_quantile_discr(X,eps,num_states_X,num_states_Y)
% g_quantile(X,eps,num_states_X,num_states_Y)


% Xhat=fct_bw(Y+1);
% eps_bw=mod(X-Xhat,num_states_X);
% chi_sq_quantile_discr(Y,eps_bw,num_states_Y,num_states_X)
% g_quantile(Y,eps_bw,num_states_Y,num_states_X)

%p=chi_sq_quant(eps,X,length(unique(eps)),length(unique(X)))
%p=chi_sq_quantile(eps,X)



%entropy
% for i=1:num_states_X
%     p(i)=sum(X==(i-1))/num_samples;
%     logp(i)=log(p(i))/log(2);
% end
% for i=1:num_states_Y
%     q(i)=sum(Y==(i-1))/num_samples;
%     logq(i)=log(q(i))/log(2);
% end
% p
% q
% entropyX=-sum(p.*logp)
% entropyY=-sum(q.*logq)
