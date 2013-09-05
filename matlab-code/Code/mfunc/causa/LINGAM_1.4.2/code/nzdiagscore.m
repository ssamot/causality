function s = nzdiagscore( W )

s = sum(1./diag(abs(W)));
    
