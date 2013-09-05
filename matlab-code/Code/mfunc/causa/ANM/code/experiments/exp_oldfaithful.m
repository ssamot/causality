% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%
% Compares models duration->interval and interval->duration using geyser data

fprintf('----------\n');
fprintf('Doing Old Faithful experiment...\n\n');

clear
A = load('-ascii','../data/geyser/geyser.dat');
x = A(:,1);  % current duration
y = A(:,2);  % next interval
format long


% forward model
fprintf('Fitting forward model...\n');
yf = fit_gp(x,y);
[pf hf] = fasthsic(x, yf - y);
fprintf('  p-value for independence: %e\n\n',pf);
A = sortrows([x y yf]); x = A(:,1); y = A(:,2); yf = A(:,3);

figure;
subplot(2,2,1);
plot(x,y,'k.'); hold on; plot(x,yf,'k-','LineWidth',2); hold off
xlabel('duration','FontSize',16);
ylabel('interval','FontSize',16);
print( '-deps', '../fig/exp_oldfaithful1.eps' )

plot(x,y-yf,'k.');
xlabel('duration','FontSize',16);
ylabel('residuals of (a)','FontSize',16);
print( '-deps', '../fig/exp_oldfaithful2.eps' )


% backward model
fprintf('Fitting backward model...\n');
xf = fit_gp(y,x);
[pb hb] = fasthsic(y, xf - x);
fprintf('  p-value for independence: %e\n\n',pb);
A = sortrows([y x xf]); y = A(:,1); x = A(:,2); xf = A(:,3);

plot(y,x,'k.'); hold on; plot(y,xf,'k-','LineWidth',2); hold off
xlabel('interval','FontSize',16);
ylabel('duration','FontSize',16);
print( '-deps', '../fig/exp_oldfaithful3.eps' )

plot(y,x-xf,'k.');
xlabel('interval','FontSize',16);
ylabel('residuals of (c)','FontSize',16);
print( '-deps', '../fig/exp_oldfaithful4.eps' )


% time-shifted data
fprintf('Using time-shifted data\n\n');
x = A(:,2);  % next interval
y = A(:,3);  % subsequent duration
fprintf('Fitting forward model...\n');
yf = fit_gp(x,y);
[pf hf] = fasthsic(x, yf - y);
fprintf('  p-value for independence: %e\n\n',pf);
fprintf('Fitting backward model...\n');
xf = fit_gp(y,x);
[pb hb] = fasthsic(y, xf - x);
fprintf('  p-value for independence: %e\n\n',pb);

close all
