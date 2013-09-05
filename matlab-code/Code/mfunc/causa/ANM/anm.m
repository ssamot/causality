function ff=anm(x, y)
%ff=anm(x, y)
% Additive Noise Model for Continuous data
% ff is positive is X->Y and negative if X<-Y
% X and Y are column vectors.

% Cause-effect pair challenge wrapper 
% Mikael Henaff and Isabelle Guyon, February 2013

fasthsic=@orighsic;
% to get the real fasthsic one must compile the C code

fp=0; % print routing handle, if 0: do not print

ff=0;
try
    dprintf(fp, 'Fitting forward model\n');
    f = fit_gp(x,y);
    [res.p_f res.stat_f] = fasthsic(x, f - y);
    dprintf(fp, '  p-value %e (h = %e)\n',res.p_f,res.stat_f);
    
    dprintf(fp, '\nFitting backward model\n');
    b = fit_gp(y,x);
    [res.p_b res.stat_b] = fasthsic(y, b - x);
    dprintf(fp, '  p-value %e (h = %e)\n',res.p_b,res.stat_b);

    ff=res.stat_b-res.stat_f;
catch
    fprintf(2, 'anm: execution failed\n');
end


