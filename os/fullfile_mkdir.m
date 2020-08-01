function [dir_or_path] = fullfile_mkdir(varargin)
% simply fullfile and mkdir
dir_or_path = fullfile(varargin{:});
try
    mkdir(dir_or_path);
catch ME
    warning("The returned path are invalid on this device. \n (%s) \n (%s)",...
        ME.getReport,dir_or_path);
end
end

