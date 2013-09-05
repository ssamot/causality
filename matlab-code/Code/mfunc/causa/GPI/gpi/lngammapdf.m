function [ lng,dlng ] = lngammapdf(x,params)
% [ln gamma, d/dx lngamma] = log gammapdf (x,k,t)
%
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
k=params(1);
t=params(2);

lng     = (k-1).*log(x) - x./t -gammaln(k) - k*log(t);
dlng    = (k-1)./x - 1/t;

