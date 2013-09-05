function good_idx=browse(this, h)
%good_idx=browse(this, h)
% Graphical display of patterns

% Isabelle Guyon -- isabelle@clopinet.com -- February 2013

if nargin<2, h=figure; else figure(h); end

good_idx=[];

N=length(this);
n=-2;
g=-3;
p=-1;
e=0;
num=1;
while 1

    show(this, num, h);
    set(h, 'Name',  ['Pattern ' num2str(num) ' / ' num2str(N)]);

    idx = input('Pattern number (or n for next, p for previous, e exit)? ');
    if isempty(idx), idx=n; end
    switch idx
    case {n, g}
        if idx==g
            good_idx=[good_idx num];
        end
        num=num+1;
        if num>N, num=1; end
    case p
        num=num-1;
        if num<1, num=N; end
    case e
        break
    otherwise
        num=idx;
    end
end


