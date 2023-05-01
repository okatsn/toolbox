% `copy_all_files(keyword, from_dir0, to_dir1, varargin)` copy files in
% `from_dir0` to directory `to_dir1`, matching `keyword` and extra
% arguments of `datalist(keyword, targetfolder, varargin)`.
function copy_all_files(keyword, from_dir0, to_dir1, varargin)
    lendir0 = length(split(from_dir0, filesep));
    lendir1 = length(split(to_dir1, filesep));
    flist = datalist(keyword, from_dir0, varargin{:}).fullpath;
    splitted_paths = cellfun(@(str) split(str, filesep), flist, 'UniformOutput', false);   
    target_paths = cellfun(@(c) join(string([{to_dir1}; c(lendir0+1:end)]), filesep), splitted_paths);
    for i = 1:length(target_paths)
        fsource = flist{i};
        fdest = target_paths{i};
        mkdir(fileparts(fdest));
        status = copyfile(fsource, fdest, 'f');
        if status ~= 1
            error("Copy file '%s' to '%s' failed.", fsource, fdest);
        end
    end
end