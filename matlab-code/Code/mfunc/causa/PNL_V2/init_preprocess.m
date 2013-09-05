function x = init_preprocess(xin)
% to make x and y closer to Gaussian

T = length(xin);
xin = xin - mean(xin);
xin = xin/std(xin);

c = [0.3 0.5 0.7 1.1 1.5];
if skewness(xin) > 0.4
    for i=1:4
        tt_trans(i,:) = log(xin - min(xin) + c(i));
    end
    Skew = skewness(tt_trans');
    [Skew_find, II] = min(abs(Skew));
    x = tt_trans(II,:);
elseif skewness(xin) < -0.4
    for i=1:4
        tt_trans(i,:) = -log(-xin + max(xin) + c(i));
    end
    Skew = skewness(tt_trans');
    [Skew_find, II] = min(abs(Skew));
    x = tt_trans(II,:);
else
    x = xin;
end