function hist_plot(INFO_X,bins,nameX)
% function hist_plot(INFO_X,bins,nameX)
%
% Visualizes a GMM p(X) by a histogram and a plot
%
% INPUT:
%   INFO_X:    struct output by e.g. by gpi_mml
%   nameX:     name for X (default: 'X')
% 
% Copyright (c) 2010  Oliver Stegle, Joris Mooij
% All rights reserved.  See the file COPYING for license terms.
%

  if nargin < 3
    nameX = 'X';
  end
  assert(size(INFO_X.X,2) == 1);
  N = length(INFO_X.X);

  % plot the data
  [hh,xx] = hist(INFO_X.X,bins);
  barplot = bar(xx,hh/N/(xx(2)-xx(1)));
  set(barplot,'EdgeColor',[0 0 1]);
  set(barplot,'FaceColor',[0 0 0.75]);

  % plot the fitted GMM
  hold on
  minX = min(INFO_X.X);
  maxX = max(INFO_X.X);
  plotgrid = minX:(maxX-minX)/500:maxX;
  mix = zeros(size(plotgrid));
  for comp=1:INFO_X.k
    mix = mix + INFO_X.pp(comp)*uninorm(plotgrid,INFO_X.mu(comp),INFO_X.cov(comp));
    plot(plotgrid,INFO_X.pp(comp)*uninorm(plotgrid,INFO_X.mu(comp),INFO_X.cov(comp)),'k')
  end
  plot(plotgrid,mix,'Color','red','LineWidth',2);
  text(plotgrid(5),0.9*max(mix),sprintf('k=%d',INFO_X.k));
  xlabel(nameX);
  hold off

return
