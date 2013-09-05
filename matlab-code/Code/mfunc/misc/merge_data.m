function merge_data(dirname, infile, outfile)
%merge_data(dirname, infile, outfile)
% Merge the cause-effect pair data from single .txt files
% in dirname containing samples of pairs of
% variables as 2 columns. Merge them into a single file in csv format
% called outfile. infile is an optional info file.
%

% Isabelle Guyon -- isabelle@clopinet.com -- April 2013

if nargin<3
    outfile='output.csv'; 
end
if nargin<2
    direc = dir('*.txt'); fns = {};
    [fns{1:length(direc),1}] = deal(direc.name);
else
    [header, ID, X]=read_file(infile);
    for k=1:length(ID)
        fns{k}=[ID{k} '.txt'];
    end
end
 
fp=fopen(outfile, 'w');
fprintf(fp, 'SampleID, A, B\n');

for k=1:length(fns)
    ID=fns{k};
    ID=ID(1:end-4);
    X=load(fns{k});
    fprintf(fp, '%s, ', ID);
    for i=1:size(X,1)
        fprintf(fp, '%d ', X(i, 1));
    end
    fprintf(fp, ', ');
    for i=1:size(X,1)
        fprintf(fp, '%d ', X(i, 2));
    end
    fprintf(fp, '\n');
end

fclose(fp);
