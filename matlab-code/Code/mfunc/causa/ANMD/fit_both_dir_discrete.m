function [fct_fw, p_val_fw, fct_bw, p_val_bw]=fit_both_dir_discrete(X,cycX,Y,cycY,level,doplots)
%-fits a discrete additive noise model in both directions X->Y and Y->X.
%
%-X and Y should both be of size (n,1), 
%
%-cycX is 1 if X should be modelled as a cyclic variable
%     and 0 if not
%-cycY is 1 if Y should be modelled as a cyclic variable
%     and 0 if not
% 
%-level denotes the significance level of the independent test after which
%the algorithm should stop looking for a solution
%
%-doplots=1 shows a plot of the function and the residuals for each
%iteration (at the end there will be plots in each case)
%
%-example:
%pars.p_X=[0.1 0.3 0.1 0.1 0.2 0.1 0.1];pars.X_values=[-3;-2;-1;0;1;3;4];
%pars2.p_n=[0.2 0.5 0.3];pars2.n_values=[-1;0;1];
%[X Y]=add_noise(500,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
%
%[fct1 p_val1 fct2 p_val2]=fit_both_dir_discrete(X,0,Y,0,0.05,0);
%
%
%
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%
%-LICENSE


if cycY==0
   [fct_fw p_val_fw]=fit_discrete(X,Y,level,doplots,0);
elseif cycY==1
   [fct_fw p_val_fw]=fit_discrete_cyclic(X,Y,level,doplots,0);
end

if cycX==0
   [fct_bw p_val_bw]=fit_discrete(Y,X,level,doplots,1);
elseif cycX==1
   [fct_bw p_val_bw]=fit_discrete_cyclic(Y,X,level,doplots,1);
end



if p_val_fw>level
    fct_fw
end
if p_val_bw>level
    fct_bw
end
%p_val_fw
if p_val_fw>level
    display('ANM could be fitted in the direction X->Y using fct_fw.');
end
%p_val_bw
if p_val_bw>level
    display('ANM could be fitted in the direction Y->X using fct_bw.');
end
if (p_val_bw>level)&(p_val_fw<level)
    display('Only one ANM could be fit. The method infers Y->X.');
end
if (p_val_bw<level)&(p_val_fw>level)
    display('Only one ANM could be fit. The method infers X->Y.');
end
if (p_val_bw<level)&(p_val_fw<level)
    display('No ANM could be fit. The method does not know the causal direction.');
end
if (p_val_bw>level)&(p_val_fw>level)
    display('Both ANM could be fit. The method does not know the causal direction.');
end
%are X and Y independent?
p_val_ind=chi_sq_quant(X,Y,length(unique(X)),length(unique(Y)));
if p_val_ind>level
    display('But note that X and Y are considered to be independent anyway. (Thus no causal relation.)');
end

