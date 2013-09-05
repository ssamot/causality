function J = computeJ(Y, B, Ve)

dim = size(B,1);
D = Ve;

% Find which bkl is modeled
nofparametersofB = sum( sum(B ~= 0) );
Index = zeros(nofparametersofB,2);
index_parametersofB = 0;
for i = 1 : dim,
    for j = 1 : dim,
        if B(i,j) ~= 0,
            index_parametersofB = index_parametersofB + 1;
            Index(index_parametersofB,:) = [i,j];
        end
    end
end

Sigmaindex = zeros(1,2);
for j = 1 : dim,
    for i = j : dim,
        Sigmaindex = [ Sigmaindex; [i,j] ];
    end
end
Sigmaindex = Sigmaindex(2 : size(Sigmaindex,1), :);

% Compute J with respect to b_{kl}
J_B = zeros( dim * (dim + 1) / 2, nofparametersofB);

for Sigmaindexi = 1 : dim * (dim + 1) / 2,
    for indexi = 1 : nofparametersofB,
        k = Index(indexi,1);
        l = Index(indexi,2);
        J_B(Sigmaindexi,indexi) = dSigmadb(Sigmaindex(Sigmaindexi,1),Sigmaindex(Sigmaindexi,2),k,l,Y,D);
    end
end

% Compute J with respect to d_{kk}
J_D = zeros( dim * (dim + 1) / 2, dim);

for Sigmaindexi = 1 : dim * (dim + 1) / 2,
    for k = 1 : dim,
        J_D(Sigmaindexi,k) =  dSigmadd(Sigmaindex(Sigmaindexi,1),Sigmaindex(Sigmaindexi,2),k,Y,D,B);
    end
end


J = [J_B, J_D];
