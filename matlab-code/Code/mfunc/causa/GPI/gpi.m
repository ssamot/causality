function f = gpi(X, Y)
% function f = gpi(X, Y)
% Gaussian Process Inference criterion
% ff is positive is X->Y and negative if X<-Y
% X and Y are column vectors.

% Cause-effect pair challenge wrapper 
% Mikael Henaff and Isabelle Guyon, February 2013

% This thing is super slow so we limit it to 100 samples (change if you
% like...

n=min(length(X), 100);

n=length(X);

X=X(1:n,:);
Y=Y(1:n,:);

f=0;
try
    % Parameters taken 'as is' from run_pairs_cluster.m from the GPI source
    % code (from Mike Henaff)
    res.CFG_XY = struct;
    res.CFG_XY.jitter = 1e-5;
    res.CFG_XY.epslabs = 1e-3;
    res.CFG_XY.priors = {[30,0.5], [30,0.5], [30,0.5]};
    res.CFG_XY.barrier = 1e2;
    % Use compiled Fortran code for L-BFGS as the minimization routine
    % res.CFG_XY.minimize = @minimize_lbfgsb;
    % Use a more numerically stable minimizer (recommended by Joris Mooij)
    res.CFG_XY.minimize = @minimize;
    % Maximum number of iterations during minimization
    res.CFG_XY.Ncg = 500;
    res.CFG_X = struct;
    res.CFG_X.reg = 1e-4;
    % Run GPI-MML
    [res.DL_XY,res.INFO_XY,res.INFO_X] = gpi_mml(X,Y,res.CFG_XY,res.CFG_X);
    [res.DL_YX,res.INFO_YX,res.INFO_Y] = gpi_mml(Y,X,res.CFG_XY,res.CFG_X);

    f=res.DL_YX-res.DL_XY;
catch
    fprintf(2, 'gpi: execution failed\n');
end

end