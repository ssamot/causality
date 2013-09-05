function [header, ID, X]=read_file(filename, verbosity)
%[header, ID, X]=read_file(filename, verbosity)
% filename --   Name of file with NO extension

% samples --    Matrix or cell array of samples (samples in lines)
% labels --     Matrix or cell array of labels (labels in lines)

%Isabelle Guyon -- February 2013 -- isabelle@clopinet.com

if ~strcmp(filename(end-3:end), '.csv'), filename=[filename '.csv']; end
if nargin<2, verbosity=0; end

if ~exist(filename, 'file'),
    X={};
    header={};
    ID={};
    return
end

if verbosity
    fprintf('Reading %s ... \n', filename);
end
X=read_mixed_csv(filename);
if verbosity
    fprintf('Done\n');
end
H=X(1,:);
header={};
if ischar(H{1}) && strcmp(H{1}, 'SampleID' )
    header=H;
    s=2;
else
    s=1;
end
ID=X(s:end,1);
X=X(s:end,2:end);

% Convert to numeric
if verbosity
    fprintf('Converting to numeric ... \n');
end
percent_done=0;
old_percent_done=0;
tic;

[p, n]=size(X);

m=n*p;
k=0;

for i=1:n
    isanum=0;
    if ~strcmp(X{1,i}, 'line') && ~isempty(str2num(X{1,i})) 
        isanum=1; 
    else
        for j=1:p
            if ~isnan(str2double(X{j,i}))
                isanum=1;
                break
            end
        end   
    end
    if isanum
        for j=1:p
            if verbosity
                percent_done=floor(k/m*100);
                if ~mod(percent_done,5) & percent_done~=old_percent_done,
                    fprintf(' %d%%(%5.2f)', percent_done, toc);
                end
                old_percent_done=percent_done;
            end
            k=k+1;
            
            x=str2num(X{j,i});
            if isempty(x), x=NaN; end
            X{j,i}=x;
        end
    end
end
if verbosity
    fprintf('Done\n');
end


end

