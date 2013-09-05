function Bpruned = olsboot(X, causalperm, threshold, nboot, Borg)
% Computes bootstrap confidence intervals using the percentile
% method and prunes edges.
% Notes:
% 1) Imposing L1 penalty could give better performance.
% 2) Performance of other methods to compute confidence intervals
% such as bootstrap-t and BCa should be investigated.
% Shohei Shimizu 29 Nov 2006

% n: N of variables. N: N of samples
[n,N] = size(X);

% Get bootstrap estimates
fprintf('Bootstrapping...\n');

% This collects bootstrap estimates
Bboot = zeros(n,n,nboot);

% Do bootstrapping
for booti = 1 : nboot

if rem(booti,ceil(nboot/10)) == 0
fprintf('[%1.0f]',booti);
end

% Generate bootstrap samples
bootindex = ceil( rand(1,N) * N );
Xboot = X(:,bootindex);

% Compute ordinary least squares estimates
Bols = ols(Xboot,causalperm);

% Collect estimates
Bboot(:,:,booti) = Bols;

end
fprintf('\n');

% Compute bootstrap confidence intervals
Bboots = sort(Bboot,3);
LB = Bboots(:,:,ceil(nboot*threshold/2));% Lower bound
UB = Bboots(:,:,ceil(nboot*(1-threshold/2)));% Upper bound

% Prune bij whose confidence intervals contain zero
Bpruned = Borg;
Bpruned( LB <=0 & UB >=0 )=0;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Bols = ols(X,k)

dims = size(X,1);

%Permute the variables to the causal order
X = X(k,:);

% Remember to subract out the mean
Xm = mean(X,2);
X = X - Xm*ones(1,size(X,2));

% Calculate covariance matrix
C = (X*X')/size(X,2);

% Do QL decomposition on the inverse square root of C
[Q,L] = tridecomp(C^(-0.5),'ql');

% The estimated disturbance-stds are one over the abs of the diag of L
olsdisturbancestd = 1./diag(abs(L));

% Normalize rows of L to unit diagonal
L = L./(diag(L)*ones(1,dims));

% Calculate corresponding B
Bols = eye(dims)-L;

% Also calculate constants
cols = L*Xm;

% Permute back to original variable order
ik = iperm(k);
Bols = Bols(ik, ik);
olsdisturbancestd = olsdisturbancestd(ik);
cols = cols(ik);

return
