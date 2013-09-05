function split_data(filename)
%split_data(filename)
% Split the cause-effect pair data into individual files
% filename: name of a csv file (with extention) that containf 3 columns:
% sample ID, A and B, where A and B contain numerical values of a
% cause-effect pair (space separated).

% Isabelle Guyon -- isabelle@clopinet.com -- April 2013

[header, ID, X]=read_file(filename);

for k=1:length(ID)
    fp=fopen([ID{k} '.txt'], 'w');
    XA=X{k, 1};
    XB=X{k, 2};
    for i=1:length(XA)
        fprintf(fp, '%d\t%d\n', XA(i), XB(i));
    end
    fclose(fp);
end

