function [thresh,testStat,params] = orighsic(X,Y,alpha,params)
%[thresh,testStat,params] = orighsic(X,Y,alpha,params)
%This function implements the HSIC independence test 
%Inputs: 
%        X contains dx columns, m rows. Each row is an i.i.d sample
%        Y contains dy columns, m rows. Each row is an i.i.d sample
%        alpha is the level of the test (default 0.05)
%        params.sigx is kernel size for x (set to median distance if -1)
%        params.sigy is kernel size for y (set to median distance if -1)
%Outputs: 
%        independent (testStat>thresh)
%        thresh: test threshold for level alpha test
%        testStat: test statistic
%Set kernel size to median distance between points, if no kernel specified

%Copyright (c) Arthur Gretton, 2007
%03/06/07


if nargin<3, alpha=0.05; end
if nargin<4,
    params.sigx=-1;
    params.sigy=-1;
end
    
[thresh,testStat,params] = hsicTestGamma(X,Y,alpha,params);
% or
%[thresh,testStat,params] = hsicTestBoot(X,Y,alpha,params);

