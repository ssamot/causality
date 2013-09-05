function [HSIC, p] = fasthsic_test(X,Y,sX,sY)
% function [HSIC, p] = fasthsic_test(X,Y,sX,sY)
%
% Calculates the Hilbert-Schmidt Independence Criterion between x and y using RBF kernels
%
% NOTE: this function is a MatLab fallback that will be used in case the fasthsic MEX file
% is missing. This MatLab fallback only implements a subset of the features offered by the 
% MEX file. In particular, it only implements the gamma approximation.
%
% INPUT:    X      = Nxd1 vector of doubles
%           Y      = Nxd2 vector of doubles
% optional: sX     = kernel bandwidth for x (automatically chosen if equal to 0.0)
%           sY     = kernel bandwidth for y (automatically chosen if equal to 0.0)
%
% OUTPUT:   p      = p-value of the HSIC
%                    (large p means independence, small p means dependence)
%           HSIC   = Hilbert Schmidt Independence Criterion estimator for X and Y
%
% Copyright (c) 2013  Joris Mooij  [j.mooij@cs.ru.nl]\n"
% All rights reserved.  See the file COPYING for the license terms\n"

debug_me =0;

if debug_me
  warning('Using matlab fallback for fasthsic...');
end

  % check arguments
  N = size(X,1);
  d1 = size(X,2);
  d2 = size(Y,2);
  if size(Y,1) ~= N
    error('Y should be a matrix with the same number of rows as X');
  end

  % estimate sX and sY, if necessary
  if nargin < 3 
    sX = 0.0;
  end
  if nargin < 4
    sY = 0.0;
  end
  if sX <= 0.0
    sX = guess_sigma(X);
    if debug_me
        fprintf('fasthsic.m: Using heuristic for HSIC kernel width sX = %e\n', sX);
    end
  end
  if sY <= 0.0
    sY = guess_sigma(Y);
    if debug_me
        fprintf('fasthsic.m: Using heuristic for HSIC kernel width sY = %e\n', sY);
    end
  end

  % calculate KX and KXbar
  KX = rbfkernel(X, sX);
  % calculate KY
  KY = rbfkernel(Y, sY);
  % calculate matrix products with H
  H = eye(N) - (1./N) * ones(N);
  KXbar = H * KX * H;
  KYbar = H * KY * H;

  % calculate HSIC
  HSIC = 1 / (N^2) * trace(KXbar * KY);

  if nargout>1
      % calculate sums of kernel matrices
      KX_sums = sum(KX, 1);
      KX_sum = sum(KX_sums);
      KY_sums = sum(KY, 1);
      KY_sum = sum(KY_sums);

      % calculate statistics for gamma approximation
      x_mu = 1.0 / (N * (N-1)) * (KX_sum - N);
      y_mu = 1.0 / (N * (N-1)) * (KY_sum - N);
      mean_H0 = (1.0 + x_mu * y_mu - x_mu - y_mu) / N;
      var_H0 = (2.0 * (N-4) * (N-5)) / (N * (N-1.0) * (N-2) * (N-3) * ((N-1)^4)) * trace(KXbar * KX) * trace(KYbar * KY);

      % calculate p-value under gamma approximation
      a = mean_H0 * mean_H0 / var_H0;
      b = N * var_H0 / mean_H0;
      p = gammainc( N * HSIC / b, a, 'upper' );
  end

return


function K = rbfkernel(X,sigma)
% function K = rbfkernel(X,sigma)
%
% Constructs isotropic RBF kernel matrix.
%
% Input:
%   X      Nxd matrix (N data points, dimensionality d)
%   sigma  bandwidth parameter
%
% Output:
%   K      kernel matrix
%
% Copyright (c) 2011-2013  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  N = size(X,1);
  d = size(X,2);

  % Calculate K(i,j) = norm(X(i,:) - X(j,:),2)^2
  if d > 1
    K = sum((repmat(reshape(X,N,1,d),[1,N,1]) - repmat(reshape(X,1,N,d),[N,1,1])).^2,3);
  else
    K = (repmat(X,1,N) - repmat(X',N,1)).^2;
  end

  K = exp(-K / (2.0 * sigma^2));
return


function [sigma] = guess_sigma(X,method)
% function [sigma] = guess_sigma(X[,method])
%
% Uses heuristic to guess "good" kernel width sigma
% 
% If method == 0, use Arthur's heuristic
% If method == 1, use the old heuristic (inspired by Arthur's heuristic)
% If method == 2, use maximizer of LOO estimator of kernel density
%
% Copyright (C) 2008-2012  Joris Mooij  <j.mooij@cs.ru.nl> 
% All rights reserved.  See the file LICENSE for license terms.

  if nargin < 2
    method = 0;
  end

  if method == 0
    % Arthur's heuristic
    Xnorm = get_norm(X);
    Xnorm = Xnorm-tril(Xnorm);
    Xnorm = reshape(Xnorm,size(X,1)^2,1);
    sigma = sqrt(0.5*median(Xnorm(Xnorm>0)));
  elseif method == 1
    Xnorm = get_norm(X);
    sigma = sqrt(0.5*median(Xnorm(:)));
  elseif method == 2
    sigma = exp(fminsearch(@(logh) kernel_LOO(exp(logh),X),0.0));
  end

return


function result=get_norm(A)
  lenA=size(A,1);
  result=zeros(lenA,lenA);
  if size(A,2) > 1
    for i1=1:lenA
      for i2=i1+1:lenA
        result(i1,i2)=sum((A(i1,:)-A(i2,:)).^2);
        result(i2,i1)=result(i1,i2);
      end
    end
  else
    for i1=1:lenA
      for i2=i1+1:lenA
        result(i1,i2)=(A(i1)-A(i2))^2;
        result(i2,i1)=result(i1,i2);
      end
    end
  end
return
