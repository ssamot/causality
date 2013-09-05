% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%
% Take Gaussian marginal and conditional and vary the parameter b in y = x + b * x^3

fprintf('----------\n');
fprintf('Doing nonlinear experiment...\n\n');

clear
alpha = 0.02;
numtries = 100;
numpoints = 300;
bvals = linspace(-1,1,31);
q = 1.0;

pf = zeros(length(bvals),numtries);
pb = zeros(length(bvals),numtries);

for i=1:length(bvals)
  for j=1:numtries
    b = bvals(i);
    x = abs(randn(numpoints,1)).^q .* sign(randn(numpoints,1));
    x = x / std(x);
    e = abs(randn(numpoints,1)).^q .* sign(randn(numpoints,1));
    e = e / std(e);
    y = x + b * x.^3 + e;

    % forward
    yf = fit_gp(x,y);
    pf(i,j) = fasthsic(x, y-yf);
    % backward
    xf = fit_gp(y,x);
    pb(i,j) = fasthsic(y, x-xf);
  end
end

save '../fig/exp_nonlinear.mat' numtries numpoints bvals pf pb

result = zeros(length(bvals),3);
for i=1:length(bvals)
  result(i,1) = bvals(i);
  result(i,2) = 1 - (sum(pf(i,:) < alpha) / numtries);
  result(i,3) = 1 - (sum(pb(i,:) < alpha) / numtries);
end
save -ascii '../fig/exp_nonlinear.dat' result


figure;
subplot(2,2,1);
plot(result(:,1),result(:,2),'b-','LineWidth',2); hold on;
plot(result(:,1),result(:,3),'r:','LineWidth',2); hold off;
xlabel('b','FontSize',16);
ylabel('p_{accept}','FontSize',16);
ylim([0 1.1]);
xlim([-1 1]);
title('q=1','FontSize',16);
print('-deps', '../fig/exp_nonlinear.eps');
close all
