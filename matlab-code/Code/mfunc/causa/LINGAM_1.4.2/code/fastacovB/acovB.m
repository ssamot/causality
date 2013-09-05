% This function compute asymptotic covariance matrix of vec{B}
% using data rawX, whitening matrix V, and estimated B
function Acov=acovB(X, B);

[dim, sample]=size(X);

% Center X
X = X - mean( X' )' * ones( 1, sample );

% Find a whitening matrix in the same manner as FastICA
C = cov(X');
[E, D] = eig (C);
V = inv (sqrt (D)) * E';

% -------------------------------------------------------- %
% Compute Asymptotic variance-covariance matrix of vec(W)
% -------------------------------------------------------- &

Z = V * X;
Acovtilde = acovW( Z, inv(V') * B );

% -------------------------------------------------------- %
% Compute Asymptotic variance-covariance matrix of vec(B)
% -------------------------------------------------------- %

G = kron( eye( dim ), V' );
Acov = G * Acovtilde * G';






