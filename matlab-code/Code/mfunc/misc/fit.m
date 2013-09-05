function [x, y, formula]=fit(x, y)
%[x, y, formula]=fit(x, y)
% Fit with constant, linear or quadratic formula
% ignore first few points
% assums line vectors

x=x(1,6:end);
y=y(1,6:end);

% constant
w=mean(y);
yhat{1}=ones(size(x))*w;
r(1)=sqrt(mean((y-yhat{1}).^2));
f{1}=sprintf('T = %5.2g', w);

% linear
xx=[x;ones(size(x))];
w=y/xx;
yhat{2}=w*xx;
r(2)=sqrt(mean((y-yhat{2}).^2));
f{2}=sprintf('T = %5.2g + %5.2g N', w(2), w(1));

% quadratic
w=(sqrt(y)/x)^2;
yhat{3}=w*x.^2;
r(3)=sqrt(mean((y-yhat{3}).^2));
f{3}=sprintf('T = %5.2g N^2', w);

% cubic
w=(y.^(1/3)/x)^3;
yhat{4}=w*x.^3;
r(4)=sqrt(mean((y-yhat{4}).^2));
f{4}=sprintf('T = %5.2g N^3', w);

% ^4
w=(y.^(1/4)/x)^4;
yhat{5}=w*x.^4;
r(5)=sqrt(mean((y-yhat{5}).^2));
f{5}=sprintf('T = %5.2g N^4', w);

[m, j]=min(r);

y=yhat{j};
formula=f{j};
