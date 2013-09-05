function set_path(root_dir)
%set_path(root_dir)
% Add all the subdirectories under the path, but removes the Octave version

if nargin<1, root_dir=pwd; end

warning off; 
addpath(genpath(root_dir));

P=path;

if strfind(computer, 'PCWIN')
    colon=[0 strfind(P, ';') length(P)+1];
else
    colon=[0 strfind(P, ':') length(P)+1];
end
for k=1:length(colon)-1
    dn=P(colon(k)+1:colon(k+1)-1);
   % fprintf('== %s\n', dn);
    if strfind(dn, 'octave')
        rmpath(dn);
    end
end
warning on





