function [imglist,varargout] = im2im(varargin)
% e.g. [~,catt]=im2im(img1,img2,img3,...) % cat all imgs (e.g. 3d unit8) along horizontal
% direction (all imgs must have the same height.)
% [imglist,catt]=im2im(img1,img2,img3,'ForceOutput','Height')
% cat all imgs (e.g. 3d unit8) along horizontal direction (all imgs resized to smallest height.)
%
% e.g. [imglist,catt]=im2im(img1,img2,img3,'ForceOutput','Width')
% Resize all inputimages to the same width, and cancatenate them along
% vertical direction (optional, depend on if there is varargout).
%
% e.g. [imglist,catt]=im2im(img1,img2,img3,'ForceOutput','Width1000')
% % Resize all inputimages to width = 1000 pixels.
keylist = {'ForceOutput'};
NoK = numel(keylist);
todo = false(1,NoK);
option_i = cell(1,NoK);
resizeWidth = {'Width','SameWidth','width'};
resizeHeight = {'Height','SameHeight','height'};
for i = 1:NoK
    keyword_at = strcmp(varargin,keylist{i});
    if any(keyword_at) % if true, do.
        idxtodel = find(keyword_at);
        option_i{i} = varargin{idxtodel+1};
        varargin(idxtodel:idxtodel+1) = []; % delete the option to prevent error
        todo(i) = true;
    else
        todo(i) = false;% do nothing, just don't export montage.
    end

end

errorStruct.message = 'Input error. Maybe you misspell something.';
errorStruct.identifier = 'Custom:Error';

if any(cellfun(@ischar,varargin)) % if there is still any strings in the varargin...
    error(errorStruct);
end

if all(cellfun(@isempty,option_i)) % if not anything to do...then cat horizontally.
%     todo(1) = true;
    option_i{1} = 'Height';
end

imglist = varargin';

S = regexp(option_i{1},'(?<type>(width|Width|height|Height))(?<res>\d+|)','names'); 
if todo(1)

    % res match to numbers or nothing.
    resize_to = NaN(1,2);
    switch S.type
        case resizeWidth
            idx_to_resize = 2;
%             resize_to = [NaN,S_res];
        case resizeHeight
%             resize_to = [S_res,NaN];
            idx_to_resize = 1;
        otherwise
            errorStruct.message = 'Wrong argument on ForceOutput';
            error(errorStruct);
    end
      
    if isempty(S.res)
        sizes = cellfun(@size,imglist,'UniformOutput',false);
        min_dim_HW = min(cell2mat(sizes));
        resize_to(idx_to_resize) =  min_dim_HW(idx_to_resize);
    else
        resize_to(idx_to_resize) =  str2double(S.res);
    end

fprintf('Resize all to the smallest %s of input figures. \n',S.type);
    NoI = numel(imglist);
    for i = 1:NoI
        imglist{i} = imresize(imglist{i},resize_to);
    end
end

if nargout>1 % then cat the figure.
    switch S.type
        case resizeWidth
            varargout{1} = vertcat(imglist{:});
        case resizeHeight
            varargout{1} = horzcat(imglist{:});
    end
end

end

