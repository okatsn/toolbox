function [imglist,varargout] = im2im(imglist,varargin)
% e.g. [~,catt]=im2im({img1,img2,img3,...}) % cat all imgs (e.g. 3d unit8) along horizontal
% direction (all imgs must have the same height.)
% e.g. [imglist,catt]=im2im({img1,img2,img3},'Width')
% Resize all inputimages to the same width, and cancatenate them along
% vertical direction (optional, depend on if there is varargout).
%
% e.g. [imglist,catt]=im2im(img1,img2,img3,'ForceOutput','Width1000')
% % Resize all inputimages to width = 1000 pixels.

% p = inputParser; %FAILED because varargin have to be name value pair or nothing
% addParameter(p,'ForceOutput',0);
% parse(p,varargin{:});
% ForceOutput = p.Results.ForceOutput;



NameOnly = {'Width','Height','AlignLeft'};
errorStruct.identifier = 'Custom:Error';


% if ~iscell(imglist) % imglist have to be cell array
%     errorStruct.message = '(Update) images should be put in a cell array at the 1st argument.';
%     error(errorStruct);
% end


%%
switch class(imglist)
    case 'cell'
       NoImg = length(imglist);
       if isa(imglist{1},'char') % if is path
           paths = imglist;
           imglist = cell(NoImg,1);

           for i = 1:NoImg
               imglist{i} = imread(paths{i});
           end
%            imgSz = size(img{1});
       else

       end
       
    case 'char'
        if isfolder(imglist) %is char and is folder, then automatically read all images into the cell.
            dl = datalist('*',imglist);
            paths = dl.fullpath;
            idx = isfile(paths);
            paths = paths(idx);
            
            NoImg = length(paths);
            imglist = cell(NoImg,1);
            
            for i = 1:NoImg
                imglist{i} = imread(paths{i});
            end
            
        else 
           if  isfile(imglist)          
                paths = {imglist};
                imglist = cell(1,1);
                imglist{1} = imread(paths{1});
           else
                errorStruct.message = 'Input string should be a folder or file path, but it is not. ';
                error(errorStruct);
               
           end
        end 
       
        

%        imgSz = size(img);
    otherwise
           imtmp = imglist; 
           imglist = cell(1,1); 
           imglist{1} = imtmp; 
           NoImg = 1; 
%            errorS.message = 'Under Construction. Not done yet';
%            error(errorS);

end



%%

[Results,varargin] = inputParser2(varargin,NameOnly);
resizeHeight = Results.Height;
resizeWidth = Results.Width;
AlignLeft = Results.AlignLeft;




p = inputParser;
addParameter(p,'ForceOutput',0);
addParameter(p,'Montage',0);
parse(p,varargin{:});
ForceOutput = p.Results.ForceOutput;
MontageProperties = p.Results.Montage;

if isequal(MontageProperties,1)
    MontageProperties = {};
end

% idx2del = strcmp({'Montage','ForceOutput'},varargin);
% varargin(idx2del) = [];
% % varargin
% if any(cellfun(@ischar,varargin)) % if there is still any strings in the varargin...
%     error(errorStruct);
% end


 
%  imglist = varargin';
NoI = numel(imglist);

SzImlist = size(imglist);
[val,idx]= max(SzImlist);
if idx ==1 % which means N by 1 cell array. Then vertical cat > "Width"
    idx_to_resize = 2;
    Direction = 1;
    
else %if idx==2 % which means 1 by N cell array. Then horzcat > "Height"
    idx_to_resize = 1;
    Direction = 2;    
end

imglist = imglist(:);% make sure it is N by 1 array. For cell2mat later.

% default
Type = 'Resize';
% idx_to_resize = 1;
% Direction = 2;

if resizeHeight
    idx_to_resize = 1;
%     Type = 'Resize';
    Direction = 2;
end

if resizeWidth
    idx_to_resize = 2;
%     Type = 'Resize';
    Direction = 1;
end

if AlignLeft
    idx_to_fill = 2;
    Type = 'Align';
    Direction = 1;
end

switch Type
    case 'Resize'
        resize_to = NaN(1,2);

        if isequal(ForceOutput,0)
            sizes = cellfun(@size,imglist,'UniformOutput',false);
            tmp = cell2mat(sizes);
            min_dim_HW = min(tmp);
            resize_to(idx_to_resize) =  min_dim_HW(idx_to_resize);
        else       
            resize_to(idx_to_resize) =  ForceOutput;
        end

%         fprintf('Resize all to the smallest %s of input figures. \n',S.type);
        
        for i = 1:NoI
            imglist{i} = imresize(imglist{i},resize_to);
        end 
    case 'Align'
        sizes = cellfun(@size,imglist,'UniformOutput',false);
        tmp = cell2mat(sizes);
        max_dim_HW = max(tmp);
        W0 =  max_dim_HW(idx_to_fill);
        for i = 1:NoI
            [H,W1,~] = size(imglist{i});
            W2 = W0 - W1;
            imglist{i} = horzcat(imglist{i},whiteimage(H,W2,'RGB'));
        end
end


if nargout>1 % then cat the figure.
    if ~isequal(MontageProperties,0)
        imgm = montage(imglist,'BackgroundColor','white',MontageProperties{:});
        varargout{1} = imgm.CData;
        
    else
    
        switch Direction
            case 1
                varargout{1} = vertcat(imglist{:});
            case 2
                varargout{1} = horzcat(imglist{:});
        end
        
    end
end

end

