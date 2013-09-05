function [A, B] = covPPiso(v, hyp, x, z)

% Piecewise polynomial covariance function with compact support, v = 0,1,2,3.
% The covariance functions are 2v times contin. diff'ble and the corresponding
% processes are hence v times  mean-square diffble. The covariance function is:
%
% k(x^p,x^q) = s2f * (1-r)_+.^j * f(r,j)
%
% where r is the distance sqrt((x^p-x^q)'*inv(P)*(x^p-x^q)), P is ell^2 times
% the unit matrix and sf2 is the signal variance. The hyperparameters are:
%
% hyp = [ log(ell)
%         log(sqrt(sf2)) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-12.
%
% See also COVFUNCTIONS.M.

if nargin<3, A = '2'; return; end                  % report number of parameters

ell = exp(hyp(1));
sf2 = exp(2*hyp(2));
if all(v~=[0,1,2,3]), error('only 0,1,2 and 3 allowed for v'), end      % degree

j = floor(size(x,2)/2)+v+1;                                           % exponent

x = x/ell;

switch v
  case 0,  f = @(r,j) 1;
          df = @(r,j) 0;
  case 1,  f = @(r,j) 1 + (j+1)*r;
          df = @(r,j)     (j+1);
  case 2,  f = @(r,j) 1 + (j+2)*r +   (  j^2+ 4*j+ 3)/ 3*r.^2;
          df = @(r,j)     (j+2)   + 2*(  j^2+ 4*j+ 3)/ 3*r;
  case 3,  f = @(r,j) 1 + (j+3)*r +   (6*j^2+36*j+45)/15*r.^2 ...
                                + (j^3+9*j^2+23*j+15)/15*r.^3;
          df = @(r,j)     (j+3)   + 2*(6*j^2+36*j+45)/15*r    ...
                                + (j^3+9*j^2+23*j+15)/ 5*r.^2;
end
 k = @(r,j,v,f)  max(1-r,0).^(j+v).*f(r,j);
dk = @(r,j,v,f)  max(1-r,0).^(j+v-1).*r.*( (j+v)*f(r,j) - max(1-r,0).*df(r,j) );

if nargin==3                                         % compute covariance matrix
  A = sf2*k( sqrt(sq_dist(x')), j, v, f );
elseif nargout==2                                 % compute test set covariances
  A = sf2*ones(size(z,1),1);
  B = sf2*k( sqrt(sq_dist(x',z'/ell)), j, v, f );
else                                               % compute derivative matrices
  if z==1
    A =   sf2*dk( sqrt(sq_dist(x')), j, v, f );
  else
    A = 2*sf2* k( sqrt(sq_dist(x')), j, v, f );
  end
end