function [A, B] = covADD(cov, hyp, x, z)

% Additive covariance function using a 1d base covariance function 
% cov(x^p,x^q;hyp) with individual hyperparameters hyp.
%
% k(x^p,x^q) = \sum_{r \in R} sf_r \sum_{|I|=r}
%                 \prod_{i \in I} cov(x^p_i,x^q_i;hyp_i)
%
% hyp = [ hyp_1
%         hyp_2
%          ...
%         hyp_D 
%         log(sf_R(1))
%          ...
%         log(sf_R(end)) ]
%
% where hyp_d are the parameters of the 1d covariance function which are shared
% over the different values of R(1) to R(end).
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-06-20.
%
% See also COVFUNCTIONS.M.

R = cov{1};
nh = eval(feval(cov{2}));           % number of hypers per individual covariance
nr = numel(R);                      % number of different degrees of interaction
if nargin<3                                  % report number of hyper parameters
  A = ['D*', int2str(nh), '+', int2str(nr)];
  return
end

[n,D] = size(x);                                                % dimensionality
sf2 = exp( 2*hyp(D*nh+(1:nr)) );        % signal variances of individual degrees

if nargin==3                                        % evaluate covariance matrix
  K = Kd(cov{2},hyp,x);                   % evaluate dimensionwise covariances K
  EE = elsympol(K,max(R));                % Rth elementary symmetric polynomials
  A = 0; for i=1:nr, A = A + sf2(i)*EE(:,:,R(i)+1); end       % sf2 weighted sum
elseif nargout==2                                 % compute test set covariances
  [kss,Ks] = Kd(cov{2},hyp,x,z);    % evaluate dimensionwise covariances kss, Ks
  E = elsympol(kss,max(R));               % Rth elementary symmetric polynomials
  A = 0; for i=1:nr, A = A + sf2(i)*E(:,:,R(i)+1); end        % sf2 weighted sum
  E = elsympol(Ks,max(R));
  B = 0; for i=1:nr, B = B + sf2(i)*E(:,:,R(i)+1); end        % sf2 weighted sum
else                                                 % compute derivative matrix
  K = Kd(cov{2},hyp,x);                   % evaluate dimensionwise covariances K
  if z <= D*nh                       % individual covariance function parameters
    j = fix(1+(z-1)/nh);              % j is the dimension of the hyperparameter
    dKj = feval(cov{2},hyp(nh*(j-1)+(1:nh)),x(:,j),z-(j-1)*nh);  % other dK zero
    % the final derivative is a sum of multilinear terms, so if only one term
    % depends on the hyperparameter under consideration, we can factorise it 
    % out and compute the sum with one degree less
    E = elsympol(K(:,:,[1:j-1,j+1:D]),max(R)-1);   %  R-1th elementary sym polyn
    A = 0; for i=1:nr, A = A + sf2(i)*E(:,:,R(i)); end        % sf2 weighted sum
    A = dKj.*A;
  else
    EE = elsympol(K,max(R));              % Rth elementary symmetric polynomials
    j = z-D*nh;
    A = 2*sf2(j)*EE(:,:,R(j)+1);                  % rest of the sf2 weighted sum
  end
end

% evaluate dimensionwise covariances K
function [K, Ks] = Kd(cov,hyp,x,z)
  [n,D] = size(x);                                              % dimensionality
  nh = eval(feval(cov));            % number of hypers per individual covariance
  if nargin==3                                                 % allocate memory
    K = zeros(n,n,D);
  else
    ns = size(z,1);                                             % dimensionality
    K = zeros(ns,1,D); Ks = zeros(n,ns,D);
  end
  for d=1:D                               
    hyp_d = hyp(nh*(d-1)+(1:nh));                 % hyperparamter of dimension d
    if nargin==3
      K(:,:,d) = feval(cov,hyp_d,x(:,d));
    else
      [K(:,:,d),Ks(:,:,d)] = feval(cov,hyp_d,x(:,d),z(:,d));
    end
  end
