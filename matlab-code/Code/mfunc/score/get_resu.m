function [Y, ID]=get_resu(filename, set_name)
%[Y, ID]=get_resu(filename, set_name)

% Isabelle Guyon -- isabelle@clopinet.com -- February 2013

if nargin<2, set_name=''; end

ID=[];
Y=[];

[~, ID, Y]=read_file(filename);

if ~isempty(set_name),
    good_idx=strmatch(set_name, ID);
    ID=ID(good_idx);
    Y=Y(good_idx);
end

Y=cell2mat(Y(:,1));

