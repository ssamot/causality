function y = elipsnorm(m,cov,level,dashed);
%
%
% draws one contour plot of a bivariate
% gaussian density with mean "m" and covariance
% matrix "cov". 
% The level is controled by "level".
% If "dashed==1", the line is dashed.
%

% -----------------------------------------------------------------------
% Copyright (2002): Mario A. T. Figueiredo and Anil K. Jain
%
% This software is distributed under the terms
% of the GNU General Public License 2.0.
% 
% Permission to use, copy, and distribute this software for
% any purpose without fee is hereby granted, provided that this entire
% notice is included in all copies of any software which is or includes
% a copy or modification of this software and in all copies of the
% supporting documentation for such software.
% This software is being provided "as is", without any express or
% implied warranty.  In particular, the authors do not make any
% representation or warranty of any kind concerning the merchantability
% of this software or its fitness for any particular purpose."
% ----------------------------------------------------------------------

if nargin<4 
   dashed=0;
end
[uu,ei,vv]=svd(cov);
a = sqrt(ei(1,1)*level*level);
b = sqrt(ei(2,2)*level*level);
theta = [0:0.01:2*pi];
xx = a*cos(theta);
yy = b*sin(theta);
cord = [xx' yy']';
cord = uu*cord;
if dashed==1
   plot(cord(1,:)+m(1),cord(2,:)+m(2),'--k','LineWidth',2)
else
   plot(cord(1,:)+m(1),cord(2,:)+m(2),'k','LineWidth',2)
end
