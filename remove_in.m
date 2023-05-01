% `remove_in(keyword, targetfolder, varargin)` remove files in `targetfolder` where `files = datalist(keyword, targetfolder, varargin{:}).fullpath;`.
function remove_in(keyword, targetfolder, varargin)
    to_delete = datalist(keyword, targetfolder, varargin{:}).fullpath;
    if isempty(to_delete)
        warning("Nothing to remove in '%s' matching %s", targetfolder, join(string(varargin)))
        return;
    end
    delete(to_delete{:})
end