function [img3] = whiteborder(img,borderlocation,borderwidth,varargin)
% whiteborder('D:\GoogleDrive\...\Probability_fb[filtered_ULF-B]_frc[20151116-20160515]',...
%     'LeftRight',150,'SaveInplace',1)
p = inputParser;
addParameter(p,'SaveInplace',false);
parse(p,varargin{:});
SaveInplace = p.Results.SaveInplace;
% borderlocation = 'RightLeftUp';
% borderwidth = [2 7 9];
addto = regexp(borderlocation,'[A-Z][a-z]*','match');
allowedkeys = {'Left','Right','Up','Down'}; % Note that the order do matter.
numkeys = length(allowedkeys);

[Lia,Locb] = ismember(addto,allowedkeys);

if ~all(Lia)
    illegalnames = addto(~Lia);
    errorstr = sprintf("Name '%s' is not an allowed border location. \n",illegalnames{:});
    error(errorstr);
end


borderwidth2 = zeros(1,numkeys);
borderwidth2(Locb) = borderwidth;

framehorz = borderwidth2(1:2); % width of left and right white frames
framevert = borderwidth2(3:4);% height of up and down white frames

id2assignval = ismember(allowedkeys,addto);

switch class(img)
    case 'cell'
        
    case 'char'
        if isfolder(img)
            img = datalist('*',img,'Search','FileOnly').fullpath;
        elseif isfile(img)
            img = {img};
        end
    otherwise
        img = {img};
end
lenim = length(img);
img3 = cell(1,lenim);
for im = 1:lenim
    imgi = img{im};
    imgi2 = imgload(imgi,'once');
    [h0,w0] = size(imgi2);
    
    
    [~,imgi2] = im2im({whiteimage(h0,framehorz(1),'RGB'),imgi2, whiteimage(h0,framehorz(2),'RGB')},...
        'Action','Exact');
    w1 = size(imgi2,2);
    [~,imgi2] = im2im({whiteimage(framevert(1),w1,'RGB');imgi2; whiteimage(framevert(2),w1,'RGB')},...
        'Action','Exact');
    
    if SaveInplace && isfile(imgi)
        imwrite(imgi2,imgi);        
    else
        img3{im} = imgi2;
    end
end


end


