function [fpath] = table2excel(inputTb,varargin)
% can be improved using writetable(T,filename)

p = inputParser;
addParameter(p,'FilePath',0);
addParameter(p,'Option',{});
parse(p,varargin{:});
r = p.Results;
openexcel = false;
defaultfpath = 'temp.xls';
if isequal(r.FilePath,0)
    fpath = pathnonrepeat(defaultfpath);
    openexcel = true;
else
    fpath = r.FilePath;
end

options = r.Option;
if ~isempty(inputTb.Properties.RowNames)
    options = [options,{'WriteRowNames'},{true}];
end

k = 1;
do1 = true;

while do1||k<10
    try
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

