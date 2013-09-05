% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%
% Take y = x + x^3 (b=0) and vary the parameter q in the probability 
% distribution, which is sampled from a Gaussian and then taken to the
% power q (with a random sign in front) and then normalized such that 
% it has variance 1

fprintf('----------\n');
fprintf('Doing non-Gaussian experiment...\n\n');

clear
alpha = 0.02;
numtries = 100;
numpoints = 300;
qvals = linspace(0.5,2,31);
b = 0.0;

pf = zeros(length(qvals),numtries);
pb = zeros(length(qvals),numtries);

for i=1:length(qvals)
  for j=1:numtries
    q = qvals(i);
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

save '../fig/exp_nongaussian.mat' numtries numpoints qvals pf pb

result = zeros(length(qvals),3);
for i=1:length(qvals)
  result(i,1) = qvals(i);
  result(i,2) = 1 - (sum(pf(i,:) < alpha) / numtries);
  result(i,3) = 1 - (sum(pb(i,:) < alpha) / numtries);
end
save -ascii '../fig/exp_nongaussian.dat' result


figure;
subplot(2,2,1);
plot(result(:,1),result(:,2),'b-','LineWidth',2); hold on;
plot(result(:,1),result(:,3),'r:','LineWidth',2); hold off;
xlabel('q','FontSize',16);
ylabel('p_{accept}','FontSize',16);
ylim([0 1.1]);
xlim([0.5 2]);
title('b=0','FontSize',16);
print('-deps', '../fig/exp_nongaussian.eps');
close all
