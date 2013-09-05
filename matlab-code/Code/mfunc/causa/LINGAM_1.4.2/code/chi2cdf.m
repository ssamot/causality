function y = chi2cdf(x, k)
% CHI2CDF The cumulative distribution function of chi^2 distribution.

y = gammainc(x / 2, k / 2);
