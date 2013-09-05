function status=makedir(directory_name)

warning off 
try
    status=mkdir(directory_name);
catch
    status=0;
end
warning on