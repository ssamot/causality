function [A] = gpi_kernel_seard(CFG, hyp, x, e, k, deriv,X2,E2)
% function [A] = gpi_kernel_seard(CFG, hyp, x, e, k, deriv, X2,E2)
%
% Special purpose ARD covariance function for GPI.
% Note that it has a different interface than the GPML covariance functions.
%
%   K = sf^2 * exp(-sq_dist(x' / L0x) / 2) .* exp(-sq_dist(e' / L0e) / 2) + sf^2 * jitter * eye(N);
%   K(i,j) = k(x1=x_i, e1=e_i, x2=x_j, e2=e_j);
%   M(i,j) = dk/de1 (x1=x_i, e1=e_i, x2=x_j, e2=e_j);
%
% where sf is the magnitude, L0x the length scale for X,
% L0e the length scale for E, and e(1)...e(N) are the noise values.
%
% INPUTS:
%   CFG:    configuration and cache object (optional)
%     .K0     the kernel matrix, without the added jitter
%     .K      the kernel matrix, with added jitter
%     .L      the Cholesky decomposition of K (L * L' = K)
%     .dKde   the partial derivative of K with respect to e1
%     .KKd1   useful for calculating the partial derivative of dKde with respect to ek
%     .jitter strength of jitter term
%   hyp:    hyperparameters:
%             [log(sf), log(L0x), log(L0e)]
%   x:      NxD inputs
%   e:      Nx1 noise values
%   k:      second input (optional)
%  deriv:   evaluate derivative with respect to (correesponding to df/de) 
% **Prediction mode**
%   X2:     Second pairs of inputs N2xD inputs
%   E2:     sNx1 noise values
%   Note: derivatives are not available if nargin>7, i.e. for X2/E2 arguments
%
% function [A] = gpi_kernel(CFG, hyp, x, e)
% OUTPUTS:
%   A:      (updated) CFG
%
% function [A] = gpi_kernel(CFG, hyp, x, e, k, deriv)
% OUTPUTS:
%   A:     k == 0:   A(i,j) = X(i,j)
%          k > 0:    A(i,j) = derivative of X(i,j) with respect to hyp(k)
%          k < 0:    A(1,j) = derivative of X(-k,j) with respect to e(-k)
%          where 
%            X == K if deriv == 0,
%            X == M if deriv == 1
%
% NOTE:    we use that the derivative with respect to e(-k) is of the form
%            ((i == k) - (j == k)) * f(i,j)
%          we only return the row vector for i == k
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%

  % N = number of data points
  % D = dimensionality of inputs 
  [N,D] = size(x);

  %hyp: sf2, L0x, L0e
  assert(length(hyp) == 3);
  sf2   = exp(2*hyp(1));
  ellx  = exp(hyp(2));
  elle  = exp(hyp(3));
  elle2 = exp(2*hyp(3));

  %fill CFG cache entries, if necessary
  if isempty(CFG) || ~isfield(CFG,'K0') || isempty(CFG.K0)
    CFG.K0 = fastkernel(x,e,ellx,elle,sf2,0);
    CFG.dKde = fastkernel(x,e,ellx,elle,sf2,1);
    CFG.KKd1 = CFG.K0 .* (dist(e/elle2).^2 - 1/elle2);
    CFG.K = CFG.K0 + CFG.jitter * eye(N);
    CFG.L = chol(CFG.K)';
  end
  
  %prediction mode? 
  if nargin>=8
    %note: we don't add jitter to the cross covariance
    A = CFG;
    A.cK = fastkernel(x,e,ellx,elle,sf2,deriv,X2,E2);
    return;
  %everything else (we ignore X2,E2)
  elseif nargin == 4
    A = CFG;
  else
    if deriv == 0
      if k == 0 %K
        A = K;
      elseif k == 1 %magnitude
        A = 2 * CFG.K0;
      elseif k == 2 %lengthscale X
        A = CFG.K0 .* sq_dist(x'/ellx); % CACHE
      elseif k == 3 %lengthscale E
        A = CFG.K0 .* sq_dist(e'/elle); % CACHE
      elseif k < 0 %noise e_k
        ek = -k;
        A = zeros(1,N);
        A(1,:) = CFG.K0(ek,:) .* ((e'-e(ek)) / elle2);
        assert(A(1,ek)==0);
        %A(1,ek) = 0;
      end
    elseif deriv == 1
      if k == 0 %M
        A = CFG.dKde;
      elseif k == 1 %magnitude
        A = 2 * CFG.dKde;
      elseif k == 2 %lengthscale X
        A = CFG.dKde .* sq_dist(x'/ellx);  % CACHE
      elseif k == 3 %lengthscale E
        A = CFG.dKde .* (sq_dist(e'/elle) - 2);  % CACHE
      elseif k < 0 %noise e_k
        ek = -k;
        A = zeros(1,N);
        A(1,:) = CFG.KKd1(ek,:);
        A(1,ek) = 0;
      end
    else
      error('deriv should be 0 or 1');
    end
  end

return
