function [Y, map, h] = cmat_display(X, h, num, noshow, sat, shownum, spnum,i,j)
%[Y, map, h] = cmat_display(X, h, num, noshow, sat, shownum, spnum,i,j)
% Display matrix X in pseudo-color after rescaling and squashing to improve contrast.
% Inputs:
% X -- matrix to be displayed (real numbers).
% Optional:
% num -- number of color levels (default 256).
% noshow -- a flag. If 1, the figure is not displayed.
% sat -- saturation level.
% shownum -- shows the numerical values in matrix
% Returns:
% Y -- rescaled matrix X (in uint8, to make an image).
% map -- colormap
% h -- image handle

% Isabelle Guyon -- April 2002-June 2006 -- isabelle@clopinet.com

if (nargin<2|isempty(h)), h=figure; else noshow=0; figure(h); end
if (nargin<3|isempty(num)), num=256; end
if (nargin<4|isempty(noshow)), noshow=0; else sat=-1; end
if (nargin<5|isempty(sat)), sat=0; end
if nargin<6, shownum=0; end

if noshow==1, sat=-1; end

% Create a colormap
if 1==2
x=1:(num/2);
b=[1-exp(-x/(num/8)),exp(-x/(num/8))];
y=(num/2):-1:1;
r=[exp(-y/(num/8)),1-exp(-y/(num/8))];
g=[exp(-y/(num/8)),exp(-x/(num/8))];
%plot(1:num,r,'r-',1:num,g,'g-',1:num,b,'b');
map=[r',g',b'];
end

if 1==2
x=1:(num/2);
b=[(0.000001+1.99*x/num).^.2,exp(-x/(num/8))];
y=(num/2):-1:1;
r=[exp(-y/(num/8)),(1-1.99*x/num).^.2];
g=[exp(-y/(num/8)),exp(-x/(num/8))];
s0=((2*[y,x]./num).^10+8.2)/10;
s=((2*[y,x]./num).^10+8)/10;
r=r.*s0;
g=g.*s;
b=b.*s0;
figure; plot(1:num,r,'r-',1:num,g,'g-',1:num,b,'b');
map=[r',g',b'];

x=1:(num/2);
b=[(0.000001+1.99*x/num).^.2,(1-1.8*x/num).^2];
y=(num/2):-1:1;
r=[(.1+1.8*x/num).^2,(1-1.99*x/num).^.2];
g=[(.1+1.8*x/num).^2,(1-1.8*x/num).^2];
s0=((2*[y,x]./num).^10+8.2)/10;
s=((2*[y,x]./num).^10+8)/10;
r=r.*s0;
g=g.*s;
b=b.*s0;
%figure; plot(1:num,r,'r-',1:num,g,'g-',1:num,b,'b');
map=[r',g',b'];
end

x=[-num/2:num/2-1]+0.5;
r=(1+tanh(7*x/num))/2;
b=1-r;
%g=2*r.*b;
g=[r(1:num/2),b(num/2+1:num)];
m=exp(-(2*x/num).^2);
r=r.*m; g=g.*m; b=b.*m; 
%figure; plot(1:num,r,'r-',1:num,g,'g-',1:num,b,'b');
map=[r',g',b'];

if 1==2
x=1:(num/2);
y=(num/2):-1:1;
b=[exp(-y/(num/8)),exp(-x/(num/8))];
r=[0.5+x/num,1-x/(num/2)];
g=[x/(num/2),1-x/num];
%plot(1:num,r,'r-',1:num,g,'g-',1:num,b,'b');
map=[g',r',b'];
end

if isempty(X), Y=[]; return, end;

if ~noshow, 
    if nargin>6
        subplot(spnum,i,j);
    end
end
if sat==0
    Y=X;
    if ~noshow, h=image(Y,'CDataMapping', 'scaled'); end
elseif sat==1
	m=min(min(X));
	M=max(max(X));
	T=min(abs(m),abs(M))/2;
    Y=T*tanh(X/T);
    if ~noshow, h=image(Y, 'CDataMapping', 'scaled'); end
elseif sat==2 % direct
	m=min(min(X));
	M=max(max(X));
	S=max(abs(m),abs(M));
    Y=((X/S)+1)/2*(num-1);
    if ~noshow, h=image(Y); end
else % sat==-1
    m=min(min(X));
	M=max(max(X));
    T=max(abs(m),abs(M));
    %Y=((X/T)+1)/2;
    Y = inormalize(X);
	Y = uint8(round(Y*(num-1)));
    if ~noshow, h=image(Y); end
end

if(~noshow) 
    if (length(unique(X))<=3)
        colormap([0 0 1;0 1 0;1 1 1]);
        for i=1:size(X,1)
            for j=1:size(X,2)
                rectangle('Position', [j-0.5,i-0.5,1,1]);
            end
        end
    else
        colormap(map);
    end
    if sat~=2 & ~(length(unique(X))<=3), colorbar; end
end
% Note: colorbar('YTickLabel', the range of X);
   

if shownum,
    color=[1 1 1];
    for i=1:size(X,1)
        for j=1:size(X,2)
            text(i,j, num2str(X(i,j)), 'Color', color, 'FontWeight', 'bold');
        end
    end
end


