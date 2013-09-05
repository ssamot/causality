function [thresh_1,testS_1,thresh_2,testS_2,fx_1,gy_1,e_1,fx_2,gy_2,e_2] =...
    CauseOrEffect_fun(x, alpha)
% function CauseOrEffect(x)
% Use of constrained nonlinear ICA for distinguishing cause from effect.
% Version 1.0, May. 15 2009
% PURPOSE:
%       to find which one of xi (i=1,2) is the cause. In particular, this 
%       function does 1) preprocessing to make xi rather clear to Gaussian,
%       2) learn the corresponding 'disturbance' under each assumed causal
%       direction, and 3) performs the independence tests to see if the 
%       assumed cause if independent from the learned disturbance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
%       x (2*T): has two rows, each of them corresponds to a continuous 
%       variable. T is the sample size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS:
%       The statistical tests results will be printed by this function. In
%       particular,
%       thresh_1,testS_1,thresh_2,testS_2: the thresholds and test
%           statistics of the independence tests associated with both
%           assumed causal directions (x->y and x<-y).
%       fx_1,gy_1,e_1: f(x), g^{-1}(y), and the estimated noise for the
%           assumed causal direction x->y.
%       fx_2,gy_2,e_2: those associated with the other causal direction
%           x<-y.       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Kun Zhang (Email: kzhang@tuebingen.mpg.de)
% This software is for non commercial use only. It is freeware but not in the public 
% domain.
% If you find any bugs, please report them to me. Thanks a lot!

% We are given x
% To avoid local optima and accelerate the learning process, we first try
% to transform the data to make them seem regular.
% A simple automatic procedure is given below. 

% Isabelle guyon changes for cause-effect pair challenge noted IG

fp=0; %IG: change that to 2 to see debug/progress info

%NOTE IG: This runs several HSIC tests, but they are limited to Ncap randomly
%selected points
Ncap=5000;

T = length(x);
x1 = x(1,:);
y1 = x(2,:);

% if we have too many data points, just randomly draw Ncap points for
% learning
if T>Ncap
    I_tmp = randperm(T);
    x1 = x1(I_tmp(1:Ncap));
    y1 = y1(I_tmp(1:Ncap));
end


% automatic initialization...
x = init_preprocess(x1);
y = init_preprocess(y1);

% normalize the data
x = x - mean(x);
x = x/std(x);
y = y - mean(y);
y = y/std(y);

% run constrained nonlinear ICA...
% x->y
% [thresh_1,testS_1,fx_1,gy_1,e_1,net_1] = efficient_PNL_fun(x,y);
[y12_1, net_1, SNR, gy_1, fx_1] = NICA_MND_pnl_noinput([y;x]); % x->y
% they are actually the negative ones...
fx_1 = -fx_1;
e_1 = y12_1(1,:);

% x <- y
% [thresh_2,testS_2,fx_2,gy_2,e_2,net_2] = efficient_PNL_fun(y,x);
[y12_2, net_2, SNR, gy_2, fx_2] = NICA_MND_pnl_noinput([x;y]); % y->x
fx_2 = -fx_2;
e_2 = y12_2(1,:);

% % % figure, subplot(4,2,1), plot(x, y, '.'); title('transformed data');
% % % subplot(4,2,2); plot(x1, y12_1(1,:),'.'); title('estiamted noise (step 1)');
% % % subplot(4,2,3); plot(y1, gy_1, '.'); title('estimated g^{-1}');
% % % subplot(4,2,4); plot(x1, fx_1, '.'); title('estimated f');
% % % subplot(4,2,6); plot(y1, y12_2(1,:),'.'); title('estiamted noise (step 1)');
% % % subplot(4,2,7); plot(x1, gy_2, '.'); title('estimated g^{-1}');
% % % subplot(4,2,8); plot(y1, fx_2, '.'); title('estimated f');

% testing...
dprintf(fp, 'Performing independence tests...\n');
%%%alpha = 0.01;
if length(x) > 2000
    params.sigx = -1;
    params.sigy = -1;
    if length(x) > Ncap
        I_tmp = randperm(length(x));
        % to test if x1 -> x2
        dprintf(fp, 'For the direction x1->x2...\n');
        [thresh_1,testS_1,params] = hsicTestGamma(e_1(I_tmp(1:Ncap))',x(I_tmp(1:Ncap))',alpha,params);
        % to test if x2 -> x1
        dprintf(fp, 'For the direction x2->x1...\n');
        [thresh_2,testS_2,params] = hsicTestGamma(e_2(I_tmp(1:Ncap))',y(I_tmp(1:Ncap))',alpha,params);
    else
        dprintf(fp, 'For the direction x1->x2...\n');
        % to test if x1 -> x2
        [thresh_1,testS_1,params] = hsicTestGamma(e_1',x',alpha,params);
        % to test if x2 -> x1
        dprintf(fp, 'For the direction x2->x1...\n');
        [thresh_2,testS_2,params] = hsicTestGamma(e_2',y',alpha,params);
    end
else
    params.shuff = 200;
    params.sigx = -1;
    params.sigy = -1;
    
    % x1 -> x2?
    dprintf(fp, 'For the direction x1->x2...\n');
    [thresh_1,testS_1] = hsicTestBoot(e_1',x',alpha,params);
    dprintf(fp, 'For the direction x2->x1...\n');
    [thresh_2,testS_2] = hsicTestBoot(e_2',y',alpha,params);
end

MI(1) = information(e_1, x);
MI(2) = information(e_2, y);

% report the independence test results and the estimated mutual information
% print the results
dprintf(fp, 'Under x1->x2, estimated mutual information = %d; \nat significance level alpha = %f, threshold = %d, and testStat = %d.\n',...
    MI(1), alpha, thresh_1, testS_1);
dprintf(fp, 'Under x1<-x2, estimated mutual information = %d; \nat significance level alpha = %f, threshold = %d, and testStat = %d.\n',...
    MI(2), alpha, thresh_2, testS_2);
dprintf(fp, '\n Note: You can see which causal direction is plausible: the smaller the statistic, the more independent the cause and disturbance are.\n');