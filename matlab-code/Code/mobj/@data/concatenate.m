function D=concatenate(D1, D2)
%D=concatenate(D1, D2)
% Concatenate two datasets

% Isabelle Guyon -- isabelle@clopinet.com -- Feb 2013

if isempty(D1), D=D2; return; end
if isempty(D2), D=D1; return; end

[dim1, num1]=size(D1.X);
[dim2, num2]=size(D2.X);

if num1~=num2
    error('Sorry, cannot do this!');
end

subidx1=get_subidx(D1);
subidx2=get_subidx(D2)+dim1;

X=[D1.X; D2.X];
Y=[D1.Y; D2.Y];
subidx=[subidx1;subidx2];

D=data(X, Y);
D=subset(D, subidx);