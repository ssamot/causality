% Move to next pair (used by data browser)

L=length(D);
num=num+1;
if num>L, num=1;end
if num<1, num=L; end

set(n2, 'String', num2str(num));
