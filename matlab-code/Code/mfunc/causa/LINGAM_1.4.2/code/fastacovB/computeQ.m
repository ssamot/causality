function Q = computeQ(Z, W)

dim = size(Z, 1);
Q = zeros( dim^2, dim^2 );

for i = 1 : dim,
    for j = 1 : dim,
        Q( 1 + dim * (i - 1) : dim + dim * (i - 1), ...
            1 + dim * (j - 1) : dim + dim * (j - 1) ) = computeQblock(i, j, Z, W);
    end
end

