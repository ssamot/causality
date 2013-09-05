function [testStat, params] = hsic(X,Y,params)
%[testStat, testResu, thresh, params] = hsic(X,Y,params)
%This function implements the HSIC independence test 
%Inputs: 
%        X contains dx columns, m rows. Each row is an i.i.d sample
%        Y contains dy columns, m rows. Each row is an i.i.d sample
%        params.sigx is kernel size for x (set to median distance if -1)
%        params.sigy is kernel size for y (set to median distance if -1)
%Outputs: 
%        testStat: test statistic
%Set kernel size to median distance between points, if no kernel specified

%Copyright (c) Arthur Gretton, 2007
%03/06/07
% Minor UI modifications I. Guyon, Jan 2013

if nargin<3,
    params.sigx=-1;
    params.sigy=-1;
    params.version=1;
end
    
if params.version==1
    testStat = FastHsicTestGamma(X,Y,params);
else
    testStat = fasthsic_test(X,Y,params.sigx,params.sigy);
end