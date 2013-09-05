% a single-entry matrix with 1 at (k,l) and zero elsewhere
function Jout = singleentryJ(dim,k,l)

Jout = zeros(dim);
Jout(k,l) = 1;
