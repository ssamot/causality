function Qblockij = computeQblock(i, j, Z, W)

dim = size(Z, 1);
S = W' * Z;

Qblockij = zeros( dim, dim );

if i == j,
    for k = 1 : dim,
        if k == i,
            Qblockij(k, :) = 2 * W(:, i)';
        else
            Qblockij(k, :) = ( 1 - mean( S(k, :).* g( S(k, :) ) ) + mean( diff_g( S(i, :) ) ) ) * W(:, k)';
        end
    end
else
    for k = 1 : dim,
        if k == j,
            Qblockij(k, :) = (1 - mean( diff_g( S(j, :) ) ) + mean( S(i, :) .* g( S(i, :) ) ) ) * W(:, i)';
            %        else
            %            Qblockij(k, :) = zeros(1, dim);
        end
    end
end

