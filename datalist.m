function [dir_list, varargout] = datalist(keyword, targetfolder, varargin)
% Get all file path information with certain search parttern.
%
% Parameters
% ----------
% keyword : str
%     Search pattern. e.g. '[Coulomb]*.txt'
% targetfolder : str
%     The fullpath of the target folder, or subfolder under pwd.
% (optional) 'Search' can be followed by either '', '*', '**', '**FolderOnly', 'FolderOnly','FileOnly'
%    Control the depth of the search. Default option is ''.
%    '': search only targetfolder (default)
%    '*': search only the 1st level subfolder of the targetfolder
%    '**': (match any characters include separator) search targetfolder and all subfolders, and so on.
%    '**FolderOnly': list only folders and all subfolders and their subfolders, and so on.
%    'FolderOnly': list only 1st level folders.
% SortBy: str or cell
%    'SortBy',{'datenum','descend'}: Sort the table using sortrows with descending 'datenum'
%    'SortBy','datenum': Sort the table using sortrows with ascending (default) 'datenum'
% Returns
% -------
% dir_list : table
%     A table contain file information.
%     1st column is path cell string, you can get it using dir_list.path
%     2nd column is file cell string, you can get it using dir_list.file
%     3rd column is name cell string, you can get it using dir_list.name
%     4th column is full path cell string, you can get it using dir_list.fullpath
%     5th column is ralative path cell string, you can get it using dir_list.relativepath
%
% Examples
% --------
% Create temp directory.
% >> system('mkdir mydir1\mydir2\mydir3');  % MS
% >> system('mkdir -p mydir1/mydir2/mydir3');  % Linux
%
% Create temp txt file.
% >> fclose(fopen('mydir1/dummy.txt', 'w'));
% >> fclose(fopen('mydir1/mydir2/dummy.txt', 'w'));
% >> fclose(fopen('mydir1/mydir2/mydir3/dummy.txt', 'w'));
%
% Search only targetfolder.
% >> file_table = datalist('*.txt', 'mydir1', 'Search', '')
%
% Search only the 1st level subfolder of the targetfolder.
% >> file_table = datalist('*.txt', 'mydir1', 'Search', '*')
%
% Search targetfolder and all subfolders, and so on.
% >> file_table = datalist('*.txt', 'mydir1', 'Search', '**')
%
% List only folders and all subfolders and their subfolders, and so on.
% >> file_table = datalist('*', 'mydir1', 'Search', '**FolderOnly')
% >> file_table = datalist('*', 'mydir1', 'Search', '**FileOnly')
%
% List only 1st level folders.
% >> file_table = datalist('*', 'mydir1', 'Search', 'FolderOnly')
%
% Remove temp directory.
% >> system('rmdir /S /Q mydir1');  %MS
% >> system('rm -rf mydir1');  % Linux

p = inputParser;
addRequired(p, 'keyword');
addRequired(p, 'targetfolder');
addParameter(p, 'Search','default_search');
% addParameter(p, 'Basic',0);
addParameter(p,'SortBy',0);
parse(p, keyword, targetfolder, varargin{:});
rslt = p.Results;

keyword = rslt.keyword;
folderName = rslt.targetfolder;
Search = rslt.Search;
% Basic = rslt.Basic;
SortBy = rslt.SortBy;


tmp = regexp(Search, '(?<SearchIn>\**)(?<SearchOption>\w*)', 'names');


if ~isempty(tmp)
    SearchIn = tmp.SearchIn;
    SearchOption = tmp.SearchOption;
else
    SearchIn = '';
    SearchOption = 'default_search';
end

% if regexp(pwd,sprintf('[A-Z]\:',filesep))==1 % if input 'D:\...'
if isempty(regexp(pwd, sprintf('[A-Z]%s:',filesep),'once')) ||  isempty(regexp(pwd,['^',filesep],'once'))
    %  if input is a directory 
    target_path = folderName;
else % if input is the name of a subfolder
    target_path = fullfile(pwd, folderName);
end

search_for = keyword; %e.g. '*.txt'
dir_info = dir(fullfile(target_path, SearchIn, search_for)); % find all .txt in the folder and all subfolders.
% For example, dir */*.txt lists all files with a txt extension exactly one folder under the current folder, 
% and dir **/*.txt lists all files with a txt extension zero or more folders under the current folder. 
% Characters next to a ** wildcard must be file separators
dir_info(ismember({dir_info.name},{'.','..'}))=[];
switch SearchOption
    case 'FolderOnly'
        dir_info(~[dir_info.isdir])=[];  % remove non-directories (only folder name and path left)
        % dir_info(strcmp({dir_info.name},'..'))=[];
        % dir_info(ismember({dir_info.name},{'.','..'}))=[];
    case 'default_search'
        
        
    case 'FileOnly'
        dir_info([dir_info.isdir]) = [];
end

num_content = numel(dir_info);

% if isequal(Basic,0) % full
    varNames = {'path', 'file','fullpath','name','date','datenum','relativepath'};
% else % basic, to save time
%     varNames = {'path','file', 'fullpath'};
% end
NoC = length(varNames);

sz = [num_content, NoC];
% varTypes = {'cellstr', 'cellstr', 'cellstr', 'cellstr', 'cellstr'};
varTypes = cell(1,NoC);
varTypes(:) = {'cellstr'};


dir_list = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);

if num_content == 0
    warning('off', 'backtrace');
    warning('Nothing found. Return an empty table.');
    warning('on', 'backtrace');
    return
end

% for i = 1:num_content
%     ext = regexp(dir_info(i).name, '\.\w+', 'match'); % erase the extension of the file
%     try
%         dir_list.name{i} = erase(dir_info(i).name, ext{end});
%     catch ME
%         switch ME.identifier
%             case 'MATLAB:badsubscript'
%                 disp('target has no extension. \n')
%             otherwise
%                 assignin('base', 'ME', ME); % to see what is the expected error.
%                 rethrow(ME);
%         end
%     end
% end
% try

% basics

dir_list.path = {dir_info.folder}';
dir_list.file = {dir_info.name}';
dir_list.fullpath = cellfun(@(x, y) fullfile(x, y), ...
    dir_list.path, dir_list.file, ...
    'UniformOutput', false);

% furthermore
% if isequal(Basic,0)
dir_list.name = regexprep(dir_list.file, '\.\w+', '');
dir_list.date = {dir_info.date}';
dir_list.datenum = {dir_info.datenum}';
dir_list.relativepath = cellfun(@(x) relativepath(x), ...
    dir_list.fullpath, ...
    'UniformOutput', false);
% end
dir_list.Properties.Description = 'datalist';

% catch ME
%     assignin('base', 'ME', ME); % to see what is the expected error.
%     rethrow(ME);
%     
% end

if ~isequal(SortBy,0) % not default, then sort
    try
        if ~iscell(SortBy)
            SortBy = {SortBy};
        end
        
        dir_list = sortrows(dir_list,SortBy{:}); %  'ascend' (default) 
    catch ME
        warning('[datalist.m] An error occurred in sorting. Table returned without sorting.');
%         assignin('base', 'error_in_datalist_sorting', ME); % to see what is the expected error.
    end
end

if nargout>1
    varargout{1} = varTypes;
end

end

% Contents below is copied and pasted at 2019/02/26.
function  rel_path = relativepath( tgt_path, act_path )
%RELATIVEPATH  returns the relative path from an actual path to the target path.
%   Both arguments must be strings with absolute paths.
%   The actual path is optional, if omitted the current dir is used instead.
%   In case the volume drive letters don't match, an absolute path will be returned.
%   If a relative path is returned, it always starts with '.\' or '..\'
%
%   Syntax:
%      rel_path = RELATIVEPATH( target_path, actual_path )
%   
%   Parameters:
%      target_path        - Path which is targetted
%      actual_path        - Start for relative path (optional, default = current dir)
%
%   Examples:
%      relativepath( 'C:\local\data\matlab' , 'C:\local' ) = '.\data\matlab\'
%      relativepath( 'A:\MyProject\'        , 'C:\local' ) = 'a:\myproject\'
%
%      relativepath( 'C:\local\data\matlab' , cd         ) is the same as
%      relativepath( 'C:\local\data\matlab'              )
%
%   See also:  ABSOLUTEPATH PATH
%   Jochen Lenz
%   Download: https://www.mathworks.com/matlabcentral/fileexchange/3858-relativepath-m

% 2nd parameter is optional:
if  nargin < 2
   act_path = cd;
end
% Predefine return string:
rel_path = '';
% Make sure strings end by a filesep character:
if  length(act_path) == 0   |   ~isequal(act_path(end),filesep)
   act_path = [act_path filesep];
end
if  length(tgt_path) == 0   |   ~isequal(tgt_path(end),filesep)
   tgt_path = [tgt_path filesep];
end
% Convert to all lowercase:
[act_path] = fileparts( lower(act_path) );
[tgt_path] = fileparts( lower(tgt_path) );
% Create a cell-array containing the directory levels:
act_path_cell = pathparts(act_path);
tgt_path_cell = pathparts(tgt_path);
% If volumes are different, return absolute path:
if  length(act_path_cell) == 0   |   length(tgt_path_cell) == 0
   return  % rel_path = ''
else
   if  ~isequal( act_path_cell{1} , tgt_path_cell{1} )
      rel_path = tgt_path;
      return
   end
end
% Remove level by level, as long as both are equal:
while  length(act_path_cell) > 0   &   length(tgt_path_cell) > 0
   if  isequal( act_path_cell{1}, tgt_path_cell{1} )
      act_path_cell(1) = [];
      tgt_path_cell(1) = [];
   else
      break
   end
end
% As much levels down ('..\') as levels are remaining in "act_path":
for  i = 1 : length(act_path_cell)
   rel_path = ['..' filesep rel_path];
end
% Relative directory levels to target directory:
for  i = 1 : length(tgt_path_cell)
   rel_path = [rel_path tgt_path_cell{i} filesep];
end
% Start with '.' or '..' :
if  isempty(rel_path)
   rel_path = ['.' filesep];
elseif  ~isequal(rel_path(1),'.')
   rel_path = ['.' filesep rel_path];
end

% ===== Modified by Kai at 2019/01/27=======
if isfile(rel_path)
    rel_path = rel_path(1:end-1);
end
% =============================
return
% -------------------------------------------------

end

function  path_cell = pathparts(path_str)
path_str = [filesep path_str filesep];
path_cell = {};
sep_pos = findstr( path_str, filesep );
for i = 1 : length(sep_pos)-1
   path_cell{i} = path_str( sep_pos(i)+1 : sep_pos(i+1)-1 );
end
return
end
