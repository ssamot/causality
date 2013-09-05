function [Y, K, header, ID]=get_truth(data_dir, set_name, K)
%[Y, K, header, ID]=get_truth(data_dir, set_name, K)
% data_dir is a directory containing 2 subdirectories 'PUBLIC' and
% 'PRIVATE' and/or a subdirectory 'KAGGLE', holding the labels.
% If K==1, use KAGGLE format for labels
% Returns:
% Y -- a (P, 2) matrix, for P samples, Y(:,1) are the truth values and Y(:,2)
%      additional information (0: Ignore this sample (Unknow targets), -1 keep
%      it (Kaggle format) OR 1 A->B, 2 A<-B, 3 A-B, 4 A|B.
% K -- Use Kaggle format or not
% header -- meaning of original columns
% ID -- Sample IDs (cell array (P, 1))

% Isabelle Guyon -- isabelle@clopinet.com -- February 2013

if nargin<2, set_name=''; end
if nargin<3, K=0; end

%if ~exist([data_dir '/PRIVATE/']), K=1; end
if ~K 
    pdir={[data_dir '/PUBLIC/'], [data_dir '/PRIVATE/']};
    pfile={'*target.csv', '*target.csv'};
else
    pdir={[data_dir '/KAGGLE/'], [data_dir '/KAGGLE/']};
    pfile={'*_train_solution.csv', '*solution.csv'};
end

ID=[];
Y=[];
header=[];
YT=[];

if strcmp(set_name, 'train') || isempty(set_name)
    % Training labels
    direc = dir([pdir{1} pfile{1}]); filenames = {};
    [filenames{1:length(direc),1}] = deal(direc.name);
    if length(filenames)>1 
        error('Multiple target training files');
        return
    end
    [header, id, y]=read_file([pdir{1} filenames{1}]);
    ID=[ID; id];
    Y=[Y; y];
end

if ~strcmp(set_name, 'train') || isempty(set_name)
    % Test and valid labels
    direc = dir([pdir{2} pfile{2}]); filenames = {};
    [filenames{1:length(direc),1}] = deal(direc.name);

    for k=1:length(filenames)   
        if ~isempty(strfind(filenames{k}, set_name)) || isempty(set_name)
            [header, id, y]=read_file([pdir{2} filenames{k}]);
            ID=[ID; id];
            Y=[Y; y];
        end
    end
end

if ~isempty(Y)
    YT0=Y(:,2);
    if isnumeric(YT0{1})
        YT=cell2mat(YT0);
    else
        K=1;
        YT=-ones(size(Y, 1), 1); % -1 for all samples except the non-training examples
                                 % that should be ingnored (unknown).
        ignored=setdiff(strmatch('Ignored', YT0), strmatch('train', ID));
        YT(ignored)=0;
    end
    Y=cell2mat(Y(:,1));
end

Y=[Y YT];