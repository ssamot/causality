function [A,B]=tridecomp(W, choice)
    
% [A,B]=tridecomp(W, choice)
% QR,RQ,QL, or LQ decomposition specified by
% choice='qr', 'rq', 'ql', or 'lq', respectively.

% Courtesy of Matthias Bethge.
    
if ~exist('choice', 'var')
    choice='qr'
end

[m,n]=size(W);
Jm=zeros(m);
Jm(m:-1:1,:)=eye(m);
Jn=zeros(n);
Jn(n:-1:1,:)=eye(n);

switch choice
    case 'qr'
        [A,B]=qr(W);
    case 'lq'
        [C,D]=qr(W');
        A=D';
        B=C';
    case 'ql'
        [C,D]=qr(Jm*W*Jn);
        A=Jm*C*Jm;
        B=Jm*D*Jn;
    case 'rq'
        [C,D]=qr(Jn*W'*Jm);
        A=(Jn*D*Jm)';
        B=(Jn*C*Jn)';
end

