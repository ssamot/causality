function D=concatenate(D1, D2)
%D=concatenate(D1, D2)
% Concatenate two datasets

% Isabelle Guyon -- isabelle@clopinet.com -- Feb 2013

if isempty(D1), D=D2; return; end
if isempty(D2), D=D1; return; end

D=concatenate@data(D1, D2);
D=CEdata(D);
D.name=[D1.name; D2.name];
D.YT=[D1.YT; D2.YT];

if isempty(D1.F1), D1.F1=cell(size(D1.YT)); end
if isempty(D1.G1), D1.G1=cell(size(D1.YT)); end
if isempty(D1.S_N1), D1.S_N1=zeros(size(D1.YT)); end

if isempty(D1.F2), D1.F2=cell(size(D1.YT)); end
if isempty(D1.G2), D1.G2=cell(size(D1.YT)); end
if isempty(D1.S_N2), D1.S_N2=zeros(size(D1.YT)); end

if isempty(D2.F1), D2.F1=cell(size(D2.YT)); end
if isempty(D2.G1), D2.G1=cell(size(D2.YT)); end
if isempty(D2.S_N1), D2.S_N1=zeros(size(D2.YT)); end

if isempty(D2.F2), D2.F2=cell(size(D2.YT)); end
if isempty(D2.G2), D2.G2=cell(size(D2.YT)); end
if isempty(D2.S_N2), D2.S_N2=zeros(size(D2.YT)); end

D.F1=[D1.F1; D2.F1];
D.G1=[D1.G1; D2.G1];
D.S_N1=[D1.S_N1; D2.S_N1];

D.F2=[D1.F2; D2.F2];
D.G2=[D1.G2; D2.G2];
D.S_N2=[D1.S_N2; D2.S_N2];
