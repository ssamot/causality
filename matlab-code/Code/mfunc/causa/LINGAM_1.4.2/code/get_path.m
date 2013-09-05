function p=get_path(dirname)
%p=get_path(dirname)

pt=path;
col=[0, strfind(pt, ':'), length(pt)];
p='';
for k=1:length(col)-1
    tt=pt(col(k)+1:col(k+1)-1);
    if strfind(tt, dirname)
        p=tt;
    end
end

     

