function ff=anmd(x, y)
%ff=anmd(x, y)
% Additive Noise Model for Discrete data
% ff is positive is X->Y and negative if X<-Y
% X and Y are column vectors.

% Cause-effect pair challenge wrapper 
% Mikael Henaff and Isabelle Guyon, February 2013

fasthsic=@orighsic;
% to get the real fasthsic one must compile the C code

fp=0; % print routing handle, if 0: do not print
alpha=0.05;

ff=0;
try
    dprintf(fp, 'Fitting forward model\n');
    [~,res.p_xy,res.stat_xy] = fit_discrete(x, y, alpha, 0, []);
    dprintf(fp, '  p-value %e (stat = %e)\n',res.p_xy,res.stat_xy);

    dprintf(fp, '\nFitting backward model\n');
    [~,res.p_yx,res.stat_yx] = fit_discrete(y, x, alpha, 0, []);
    dprintf(fp, '  p-value %e (stat = %e)\n',res.p_yx,res.stat_yx);
    
    ff=res.stat_yx-res.stat_xy;
catch
    fprintf(2, 'anmd: execution failed\n');
end


