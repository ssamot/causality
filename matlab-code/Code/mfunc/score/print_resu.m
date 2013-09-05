function print_resu(filename, R)
%print_resu(filename, R)

% Isabelle Guyon -- isabelle@clopinet.com -- February 2013

fp=fopen([filename '.txt'], 'w');

fn=length(R.filenames);
tn=length(R.types);
% First print all scores for the test data, if available
% otherwise print them for the training data



t=strmatch('test', R.types);
if isnan(sum(R.Score(:,t)))
    t=strmatch('train', R.types);
    tlist=1;
    lprintf(fp, '\n\n** All scores for TRAINING set only ***\n\n');
else
    tlist=1:3;
    lprintf(fp, '\n\n** All scores for TEST set only ***\n\n');
end

lprintf(fp, 'Depen\tConf\tCausa\tScore\tFilename\n');
for k=1:fn
    lprintf(fp, '%5.5f\t%5.5f\t%5.5f\t%5.5f\t%s\n', ...
            R.Dependency(k, t), ...
            R.Confounding(k, t), ...
            R.Causality(k, t), ...
            R.Score(k, t), ...
            R.filenames{k});
end

% Then print the ranking score only, for all sets
lprintf(fp, '\n\n** Available ranking scores ***\n\n');
for k=tlist, lprintf(fp, '%s\t', upper(R.types{k})); end
lprintf(fp, 'Filename\n');

for k=1:fn
    for i=tlist
        lprintf(fp, '%5.5f\t', R.Score(k, i));
    end
    lprintf(fp, '%s\n', R.filenames{k});
end

fclose(fp);
end
