function [dir_or_path] = fullfile_mkdir(varargin)
% simply fullfile and mkdir
dir_or_path = fullfile(varargin{:});
mkdir(dir_or_path);
end

