% Calculation of entropy of a given sequence 
%Input X, Y
%Author and Copyright: Abhijit Chaudhari, CSUN. November 19th, 2000 

%---------------------------------------------------------------------------------------------------
% Module 1
% Quantizing the vectors
% Input vector X, Y
% Output l, A, B


l=sum(X)/length(X);
if l >=0
A=X >l;
else
G= X > l;
N=[ ones, length(X)];
A=xor(G,N);
end
l=sum(Y)/length(Y);
if l>=0
B=Y>l;
else
G=Y>l;
N=[ ones, length(X)];
B=xor(G,N);
end


%---------------------------------------------------------------------------------------------------
% Module 2
% Calculation of individual entropies.
% Input vectors A, B
% Output Entropy_of_A, Entropy_of_B


[i j]= find(A==1);%[j=columns in which 1 occurs
b=length(j);
c=length(A);
p1=b/c;% probability of 1
p0=1-(b/c);% probability of zero
if p1==0
q=0;
else
q=-p1*log2(p1);
end
if p0==0
f=0;
else
f=-p0*log2(p0);
end
Entropy_of_A= f+q;
[i j]= find(B==1);%[j=columns in which 1 occurs
b=length(j);
c=length(B);
p1=b/c;% probability of 1
p0=1-(b/c);% probability of zero
if p1==0
q=0;
else
q=-p1*log2(p1);
end
if p0==0
f=0;
else
f=-p0*log2(p0);
end
Entropy_of_B= q+f;


%-----------------------------------------------------------------------------------------------------
% Module 3
% Joint_entropy of two time series
% Input series A and B
% Output a, b, c, d, Joint_entropy
a=0;
b=0;
c=0;
d=0;
if A(1)==0
if B(1)==0
a=a+1;
else
b=b+1;
end
elseif A(1)==1
if B(1)==0
c=c+1;
else
d=d+1;
end
end
if A(2)==0
if B(2)==0
a=a+1;
else
b=b+1
end
elseif A(2)==1
if B(2)==0
c=c+1;
else
d=d+1;
end
end
if A(3)==0
if B(3)==0
a=a+1;
else
b=b+1;
end
elseif A(3)==1
if B(3)==0
c=c+1;
else
d=d+1;
end
end
if A(4)==0
if B(4)==0
a=a+1;
else
b=b+1;
end
elseif A(4)==1
if B(4)==0
c=c+1;
else
d=d+1;
end
end
if A(5)==0
if B(5)==0
a=a+1;
else
b=b+1;
end
elseif A(5)==1
if B(5)==0
c=c+1;
else
d=d+1;
end
end
j=length(A);
p00=a/j;
p01=b/j;
p10=c/j;
p11=d/j;
% For conditions when a, b, c or d =0
if p00==0
w = 0;
else
w=-p00*log2(p00);
end
if p01==0
x = 0;
else
x=-p01*log2(p01);
end
if p10==0
y = 0;
else
y=-p10*log2(p10);
end
if p11==0
z = 0;
else
z=-p11*log2(p11);
end
Joint_entropy=w+x+y+z;
%--------------------------------------------------------------------------------------
% Calculation of Mutual entropy
% Inputs Entropy_of_A, Entropy_of_B,Joint_entropy
% Output= Mutual_entropy
Mutual_entropy = Entropy_of_A + Entropy_of_B - Joint_entropy;
%-----------------------------------------------------------------------------------------
% Printing out the results
Entropy_of_A
Entropy_of_B
Joint_entropy
Mutual_entropy 
