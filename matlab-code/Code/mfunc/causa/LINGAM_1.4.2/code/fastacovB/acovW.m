function Acov = acovW( Z, W );

[dim, sample] = size( Z );

% -------------------------------------------------------- %
% Compute sample covariance matrix of f, covf
% -------------------------------------------------------- %

covf = zeros( dim^2, dim^2, sample );

for i = 1 : sample,
    fi = fk(Z, W, i);
    covf(:, :, i) = fi * fi';
end

covf = mean( covf, 3 );

if exist('OCTAVE_VERSION')
    % In Octave, mean returns a 3-D matrix. So we must
    % get rid of the extra dimension.
    covfTemp = covf;
    covf = zeros(size(covf, 1), size(covf, 2));
    covf(:, :) = covfTemp(:, :, 1);
end

% -------------------------------------------------------- %
% Compute sample Q
% -------------------------------------------------------- %

Q = computeQ(Z, W);

% -------------------------------------------------------- %
% Compute Acov
% -------------------------------------------------------- %

invQ = inv( Q );
Acov = invQ * covf * ( invQ )';
Acov = Acov / sample;
