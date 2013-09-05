function K = covPeriodic(hyp, x, z, i)

% covariance function for a smooth periodic 1d functions, with unit period:
%
% k(x^p, x^q) = sf2 * exp( -2*sin^2( lam*(x_p-x_q)/(2*pi) )/ell^2 )
%
% where the hyperparameters are:
%
% hyp = [ log(ell)
%         log(lam)
%         log(sqrt(sf2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-09-10.
%
% See also COVFUNCTIONS.M.

if nargin<2, K = '3'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode

n = size(x,1); nz = size(z,1);
ell = exp(hyp(1));
lam = exp(hyp(2));
sf2 = exp(2*hyp(3));

% precompute distances
if dg                                                               % vector kxx
  K = zeros(nz,1);
else
  if xeqz                                                 % symmetric matrix Kxx
    K = repmat(x,1,n )-repmat(x',n,1);
  else                                                   % cross covariances Kxz
    K = repmat(x,1,nz)-repmat(z',n,1);
  end
end

if nargin<4                                                        % covariances
  K = sf2*exp(-2*(sin( lam*K/(2*pi) )/ell).^2);
else                                                               % derivatives
  R = lam*K/(2*pi);
  if i==1
    R = (sin(R)/ell).^2;
    K = 4*sf2*exp(-2*R).*R;
  elseif i==2
    sRe = sin(R)/ell;
    K = -4/ell*sf2*exp(-2*sRe.^2).*sRe.*cos(R).*R;
  elseif i==3
    K = 2*sf2*exp(-2*(sin(R)/ell).^2);
  else
    error('Unknown hyperparameter')
  end
end