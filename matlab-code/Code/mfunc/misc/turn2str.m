function s=turn2str(a)
% s=turn2str(a)
% Turn a into a string

if ischar(a)
    s=a;
elseif isnumeric(a)
    if length(a)==1
        s=num2str(a);
    else
        s=mat2str(a);
    end
elseif ~isempty(strmatch('turn2str', methods(a)))
    s=turn2str(a);
else
    s='';
end
    