function [img2] = imgload(img,varargin)
% Load image(s) from a path or paths from datalist() or just add a cell to
% the input one.
if ~isempty(varargin) && strcmp('once',varargin{end})
    varargin(end) = [];
    do_once = true;
else
    do_once = false;
end


p = inputParser;
addParameter(p,'datalistOption',{});
parse(p,varargin{:});
datalistOption = p.Results.datalistOption;

switch class(img)
    case 'cell'
       NoImg = numel(img);       
       paths = img;
       img2 = cell(size(paths));
       deleteempty = false;
       
    case 'char'
        if isfolder(img)
            dl = datalist('*',img,datalistOption{:});
            paths = dl.fullpath;
            idx = isfile(paths);
            paths = paths(idx);
            NoImg = length(paths);
            img2 = cell(NoImg,1);         
            deleteempty = true;
        elseif isfile(img)
           paths = {img};
           img2 = cell(1,1);
           NoImg = 1; 
           deleteempty = false;
        else
            error('Input is not a valid file or folder')
        end 
       
    otherwise
           error('First argument have to be an cell array of paths or a char array of a file.')


end
showwarning = ~deleteempty;
if do_once
    NoImg = 1;
end

for i = 1:NoImg
   try
       img2{i} = imread(paths{i});
   catch
       img2{i} = [];
       if showwarning
           warning('[imgload] Error in imread. Return empty to cell %d',i);
       end
   end
end

if do_once
    img2 = img2{1};
    return
end

if deleteempty
    img2(cellfun(@isempty,img2)) = [];
end

end

