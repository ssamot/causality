function [testStat,params] = FastHsicTestGamma(X,Y, params)
%[testStat,params] = FastHsicTestGamma(X,Y,params)
%This function implements the HSIC independence test using a Gamma approximation
%to the test threshold
%Inputs: 
%        X contains dx columns, m rows. Each row is an i.i.d sample
%        Y contains dy columns, m rows. Each row is an i.i.d sample
%        params.sigx is kernel size for x (set to median distance if -1)
%        params.sigy is kernel size for y (set to median distance if -1)
%Outputs: 
%        testStat: test statistic
% Set kernel size to median distance between points, if no kernel specified

%Copyright (c) Arthur Gretton, 2007
%03/06/07

% Just return the test statistic -- IG March 2013
% This is like a correlation coefficient
    
m=size(X,1);

%Set kernel size to median distance between points, if no kernel specified
%Use at most 100 points to compute median, to save time.
if params.sigx == -1
    size1=size(X,1);
    if size1>100
      Xmed = X(1:100,:);
      size1 = 100;
    else
      Xmed = X;
    end
    G = sum((Xmed.*Xmed),2);
    Q = repmat(G,1,size1);
    R = repmat(G',size1,1);
    dists = Q + R - 2*Xmed*Xmed';
    dists = dists-tril(dists);
    dists=reshape(dists,size1^2,1);
    params.sigx = sqrt(0.5*median(dists(dists>0)));  %rbf_dot has factor of two in kernel
end

if params.sigy == -1
    size1=size(Y,1);
    if size1>100
      Ymed = Y(1:100,:);
      size1 = 100;
    else
      Ymed = Y;
    end    
    G = sum((Ymed.*Ymed),2);
    Q = repmat(G,1,size1);
    R = repmat(G',size1,1);
    dists = Q + R - 2*Ymed*Ymed';
    dists = dists-tril(dists);
    dists=reshape(dists,size1^2,1);
    params.sigy = sqrt(0.5*median(dists(dists>0)));
end



bone = ones(m,1);
H = eye(m)-1/m*ones(m,m);


K = rbf_dot(X,X,params.sigx);
L = rbf_dot(Y,Y,params.sigy);

Kc = H*K*H; 
Lc = H*L*H;
  
testStat = 1/m * sum(sum(Kc'.*Lc));    %%%% TEST STATISTIC: m*HSICb
  
