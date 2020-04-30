% fullpath = mkdir_if_not_exist(fullpath)
function fullpath = mkdir_if_not_exist(fullpath)
warning('mkdir_if_not_exist will be deprecated. Consider using mkdir or validpath.');
if exist(fullpath, 'dir')
   disp('folder already exists')
 else
    warning('folder not exist. Folder created.');
    mkdir(fullpath);
end
end

