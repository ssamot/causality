function dataname=find_name(public_data_dir)
%dataname=find_name(public_data_dir)

direc = dir([public_data_dir '/CEdata*']); filenames = {};
[filenames{1:length(direc),1}] = deal(direc.name);
dataname='CEdata';
if isempty(filenames)
    direc = dir([public_data_dir '/sample*']); filenames = {};
    [filenames{1:length(direc),1}] = deal(direc.name);
    dataname='sample';
end
if isempty(filenames)
    error('No data found, check the directory name');
end

end