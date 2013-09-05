function write_file(filename, samples, labels, type, mode, coma_end, separator, offset, header)
%write_file(filename, samples, labels, type, mode, coma_end, separator, offset, header)
% filename --   Name of file with NO extension
% samples --    Matrix or cell array of samples (samples in lines)
% labels --     Matrix or cell array of labels (labels in lines)
% Write labels in Kaggle csv format

%Isabelle Guyon -- February 2013 -- isabelle@clopinet.com

if nargin<2, error('write_file: missing samples'); end
if nargin<3, samples=[]; end
if nargin<4 || isempty(type), type=''; end
if nargin<5 || isempty(mode), mode='w'; end
if nargin<6 || isempty(coma_end), coma_end=0; end
if nargin<7 || isempty(separator), separator=''; end
if nargin<8 || isempty(offset), offset=0; end
if nargin<9, header=[]; end

fp=fopen([filename '.csv'] , mode);

if ~isempty(header)
    for k=1:length(header)-1
        fprintf(fp, '%s,%s', header{k}, separator);
    end
    fprintf(fp, '%s\n', header{end});
end

[snum, fnum]=size(samples);
snum2=size(labels);
snum=max(snum, snum2);
for k=1:snum
	num=k+offset;
    
    % Print the sample ID
    fprintf(fp, '%s%d,%s', type, num, separator);

    if ~isempty(samples)
        fmt='%g';

        % Print the sample 
        if iscell(samples) && fnum==1;
            sample=turn2str(samples{k});
            fmt='%s';
        else
            sample=samples(k,:);
        end
        if isnumeric(sample)
            for i=1:length(sample)-1
                fprintf(fp, [fmt '%s'], sample(i), separator);
            end
            fprintf(fp, fmt,  sample(end));
        elseif iscell(sample)
            for i=1:length(sample)-1
                fprintf(fp, '%s,%s', turn2str(sample{i}), separator);
            end
            fprintf(fp, '%s',  sample{end});        
        else
            fprintf(fp, '%s', turn2str(sample));
        end
    end

    if ~isempty(labels)
        % Print the labels
        fmt='%g';
        if iscell(labels)
            lbl=turn2str(labels{k});
            fmt='%s';
        else
            lbl=labels(k,:);
        end
        if ~isempty(lbl)
            if ~isempty(samples), fprintf(fp, ',%s', separator); end
            for i=1:length(lbl)-1+coma_end
                fprintf(fp, [fmt '%s,'], lbl(i), separator);
            end
            if ~coma_end
                fprintf(fp, fmt,  lbl(end));
            end
        end
    end
    fprintf(fp, '\n');
end
fclose(fp);


end

