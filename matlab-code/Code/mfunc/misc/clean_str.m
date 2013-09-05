function s=clean_str(s)
%s=clean_str(s)

s(s=='_')='-';
s(s==',')=';';
s(s=='"')='';
                