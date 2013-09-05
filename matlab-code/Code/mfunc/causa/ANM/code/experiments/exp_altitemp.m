% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.
%
% Compares models altitude->temperature and temperature->altitude using DWD weather data

fprintf('----------\n');
fprintf('Doing DWD weather data experiment...\n\n');

clear
A = load('-ascii','../data/dwd/dwd.dat');
x = A(:,1);  % altitude
y = A(:,5);  % temperature
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
xlabel('altitude','FontSize',16);
ylabel('temperature','FontSize',16);
print( '-deps', '../fig/exp_altitemp1.eps' )

plot(x,y-yf,'k.');
xlabel('altitude','FontSize',16);
ylabel('residuals of (a)','FontSize',16);
print( '-deps', '../fig/exp_altitemp2.eps' )


% backward model
fprintf('Fitting backward model...\n');
xf = fit_gp(y,x);
[pb hb] = fasthsic(y, xf - x);
fprintf('  p-value for independence: %e\n\n',pb);
A = sortrows([y x xf]); y = A(:,1); x = A(:,2); xf = A(:,3);

plot(y,x,'k.'); hold on; plot(y,xf,'k-','LineWidth',2); hold off
xlabel('temperature','FontSize',16);
ylabel('altitude','FontSize',16);
print( '-deps', '../fig/exp_altitemp3.eps' )

plot(y,x-xf,'k.');
xlabel('temperature','FontSize',16);
ylabel('residuals of (c)','FontSize',16);
print( '-deps', '../fig/exp_altitemp4.eps' )

close all
