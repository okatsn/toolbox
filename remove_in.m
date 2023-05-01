% `remove_in(keyword, targetfolder, varargin)` remove files in `targetfolder` where `files = datalist(keyword, targetfolder, varargin{:}).fullpath;`.
function remove_in(keyword, targetfolder, varargin)
    to_delete = datalist(keyword, targetfolder, varargin{:}).fullpath;
    delete(to_delete{:}, targetfolder)
end