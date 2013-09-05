function fkout = fk(Z, W, k)

[dim, sample] = size(Z);

y = W' * Z(:, k);
ygy = y * g(y)';

fkout = y * y' - eye( dim ) + ygy - ygy';

fkout = fkout( : );