% Move to any pair (used by data browser)

answer=inputdlg('Enter number:','Jump to',1, {num2str(num)}); 
if ~isempty(answer), num=str2num(answer{1}); end

if num>L, num=L;end
if num<1, num=1; end

set(n2, 'String', num2str(num));
