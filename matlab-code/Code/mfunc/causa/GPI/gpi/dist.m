function C = dist(a, b)
% function C = dist(a, b)
%
% Computes a matrix of all pairwise distances between two vectors
% 
% INPUTS:
%   a:      nx1 vector
%   b:      mx1 vector (if omitted, b = a is assumed)
%
% OUTPUT:
%   C:      nxm matric C such that C(i,j) = a(i) - b(j)
% 
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.

  if nargin<1 || nargin>2 || nargout>1
    error('Wrong number of arguments.');
  end

  if nargin==1 || isempty(b)
    b = a;
  end 

  [n, d] = size(a); 
  [m, D] = size(b);
  assert(d==1);
  assert(D==1);

  C = repmat(a,1,m) - repmat(b',n,1);

return
