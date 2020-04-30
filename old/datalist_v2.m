%% to do: 
% 1. use keyword to get the data list
% 2. use keyword to get the list of sub-folders
%  INPUT:
%  Required:
%    keyword: e.g. '[Coulomb]*.txt'
%    targetfolder: The fullpath of the target folder, or subfolder under pwd.
%
%  Parameters:
%    Search = ''; % search only targetfolder (default)
%    Search = '*'; % search only the 1st level subfolder of the targetfolder
%    Search = '**'; (match any characters include separator) % search targetfolder and all subfolders, and so on.
%    Search = '**FolderOnly'; list only folders and all subfolders and their subfolders, and so on.
%    Search = 'FolderOnly'; list only 1st level folders.
% 
%  OUTPUT:
% path_list = dir_list(:,1); 
% file_list = dir_list(:,2); 
% name_list = dir_list(:,3); 
% fullpath_list = dir_list(:,4); 


function [dir_list varargout] = datalist_v2(keyword,targetfolder,varargin)

   SearchOption1 = 'FolderOnly';
   p = inputParser;
   addRequired(p,'keyword'); % e.g. 
   addRequired(p,'targetfolder'); % e.g. '地磁資料'
   % addOptional(p,'pig',0);
   addParameter(p,'Search','default_search');      %Parameter則必須是 Name-value pair arguments 輸入。
   parse(p,keyword,targetfolder,varargin{:});
   rslt = p.Results;

   keyword = rslt.keyword;
   folderName = rslt.targetfolder;
   Search = rslt.Search; 

   tmp = regexp(Search,'(?<SearchIn>\**)(?<SearchOption>\w*)','names');
   SearchIn = tmp.SearchIn;
   SearchOption = tmp.SearchOption;
%    assignin('base','SearchOption',SearchOption);% for debug
   
   
if regexp(pwd,'[A-Z]\:')==1 % if input 'D:\...'
    target_path = folderName;
else
    target_path = fullfile(pwd,folderName);
end

search_for = keyword; %e.g. '*.txt'
dir_info = dir(fullfile(target_path,SearchIn,search_for)); % find all .txt in the folder and all subfolders.
% assignin('base','dir_info',dir_info);% for debug
if strcmp(SearchOption,SearchOption1)
    dir_info(~[dir_info.isdir])=[];%remove non-directories (only folder name and path left)
%     dir_info(strcmp({dir_info.name},'..'))=[];
    dir_info(ismember({dir_info.name},{'.','..'}))=[];
end


dir_list = cell(numel(dir_info),4);
for i = 1:numel(dir_info)
    dir_list{i,1} = dir_info(i).folder;
    dir_list{i,2} = dir_info(i).name;
    ext = regexp(dir_info(i).name,'\.\w+','match'); % erase the extension of the file
    try
    dir_list{i,3} = erase(dir_info(i).name,ext{end});
    catch ME
        switch ME.identifier
            case 'MATLAB:badsubscript'
                disp('target has no extension. \n')
            otherwise
                assignin('base','ME',ME); % to see what is the expected error.
                rethrow(ME);
        end 
    end
    dir_list{i,4} = fullfile(dir_info(i).folder,dir_info(i).name);

end
%data.dir_list = dir_list;
warning('datalist_v2 is going to be removed in future. Use datalist.m instead.');
end

