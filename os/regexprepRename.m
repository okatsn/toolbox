function regexprepRename(pathlist,match_patterns,replaced_by,varargin)
% rename files (make copies with new names) using regexprepx.
% Input arguments:
%     pathlist: an cell array containing path of the file, or simply a path (char)
%     match_patterns: see doc in regexprepx
%     replaced_by: see doc in regexprepx

p = inputParser;
addParameter(p,'Delete',false);
parse(p,varargin{:});
to_delete = p.Results.Delete;

if ischar(pathlist)
    pathlist = {pathlist};
end

if ischar(match_patterns)
    match_patterns = {match_patterns};
end

if ischar(replaced_by)
    replaced_by = {replaced_by};
end

for i = 1:length(pathlist)
    oldpath = pathlist{i};
    [fdir,fname,fext] = fileparts(oldpath);
    fname_ext = [fname,fext];
    newfname = regexprepx(fname_ext,match_patterns,replaced_by);
    if strcmp(newfname,fname_ext)
        continue
    end
    newpath = fullfile(fdir,newfname);
    copyfile(oldpath,newpath);
    if to_delete
        delete(oldpath);
    end
end
end

