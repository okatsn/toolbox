function [fpath] = table2excel(inputTb,varargin)
% Assignment of filename can be improved, using writetable(T,filename)

p = inputParser;
addParameter(p,'Folder',0);
addParameter(p,'File',0);
addParameter(p,'Option',{});
parse(p,varargin{:});
r = p.Results;
% r.FolderName = varargin{1};
% r.FileName = varargin{2};
openexcel = false;
if isequal(r.Folder,0)
    folderNm = fullfile(pwd,'temp');
    openexcel = true;
else
    folderNm = r.Folder;
end
validpath(folderNm,'mkdir');
% fname = 'temp.xls';

if isequal(r.File,0)
    prefix = 'temp';
else
    prefix = r.File;
end

options = r.Option;
if ~isempty(inputTb.Properties.RowNames)
    options = [options,{'WriteRowNames'},{true}];
end

k = 1;
do1 = true;

while do1||k<10
    try
        fname = sprintf( '%s(%d).xls',prefix,k);
        fpath = fullfile(folderNm,fname);
        writetable(inputTb,fpath,options{:});
        do1 = false;
        k=10;
    catch ME
        switch ME.identifier
            case 'MATLAB:table:write:FileOpenInAnotherProcess'
                k = k +1;
            otherwise
                rethrow(ME);
        end
    end
end
if openexcel
    winopen(fpath);
end
end

