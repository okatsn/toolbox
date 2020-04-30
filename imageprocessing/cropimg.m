function [img2] = cropimg(img,varargin)
p = inputParser;
addParameter(p,'EdgeCrop',{'up','down','left','right'});
addParameter(p,'SaveInplace',false);
% addParameter(p,'SameDim',false); % if true, only detect padding to crop once to save time.
parse(p,varargin{:});
EdgeCrop = p.Results.EdgeCrop;
SaveInplace = p.Results.SaveInplace;
% SameDim = p.Results.SameDim;
errorS.identifier = 'Custom:Error';



switch class(img)
    case 'cell'
       NoImg = length(img);
       if validpath(img{1})%isa(img{1},'char') % if is path
           paths = img;
           img = cell(NoImg,1);

           for i = 1:NoImg
               img{i} = imread(paths{i});
           end
%            imgSz = size(img{1});
       else
           NoImg = length(img);
           %do nothing
           
%            errorS.message = 'Under Construction. Not done yet';
%            error(errorS);
%            imgSz = size(img{1});
       end
       
    case 'char'
        if isfolder(img)
            dl = datalist('*',img);
            paths = dl.fullpath;
            idx = isfile(paths);
            paths = paths(idx);
            
            NoImg = length(paths);
            img = cell(NoImg,1);
            
            for i = 1:NoImg
                img{i} = imread(paths{i});
            end
            
        else
           paths = {img};
           img = cell(1,1);
           img{1} = imread(paths{1});
           NoImg = 1; 
        end 
       
        

%        imgSz = size(img);
    otherwise
           imtmp = img; 
           img = cell(1,1); 
           img{1} = imtmp; 
           NoImg = 1; 
%            errorS.message = 'Under Construction. Not done yet';
%            error(errorS);

end
img2 = cell(size(img));

if isequal(EdgeCrop,1)
    EdgeCrop = {'up','down','left','right'};
end
    dl = 20;
    thrW = 0;

for i = 1:NoImg
    
    
%     if SameDim && i>1
        
%     else
        imgSz = size(img{i});
        imgSz=increseDim(imgSz);
        imgsum = sum(img{i},3);
%     end
    
    leftbound = 1;
    lowerbound = imgSz(1);
    upperbound = 1;
    rightbound = imgSz(2);
    
%     
    up2downRow = [1:dl:imgSz(1)];
    down2upRow = fliplr(up2downRow);
    left2rightCol = [1:dl:imgSz(2)];
    right2leftCol = fliplr(left2rightCol);
%     
    

    for k = 1:length(EdgeCrop)
    notAllWhite = 0;    
        switch EdgeCrop{k}
            case 'up'               
                for l = up2downRow
                    sumrow = sum(imgsum(l,:));
                    numrow = 2; % numel of 1d array
                    notAllWhite = updown(imgSz,notAllWhite,sumrow,numrow);
                    if notAllWhite > thrW
                        upperbound = l-dl;
                        break
                    end
                end
            case 'down'
                for l = down2upRow
                    sumrow = sum(imgsum(l,:));
                    numrow = 2; % numel of 1d array
                    notAllWhite = updown(imgSz,notAllWhite,sumrow,numrow);
                    if notAllWhite > thrW
                        lowerbound = l+dl;
                        break
                    end
                end
            case 'left'
                for l = left2rightCol
                    sumrow = sum(imgsum(:,l));
                    numrow = 1; % numel of 1d array
                    notAllWhite = updown(imgSz,notAllWhite,sumrow,numrow);
                    if notAllWhite > thrW
                        leftbound = l-dl;
                        break
                    end
                end
            case 'right'
                for l = right2leftCol
                    sumrow = sum(imgsum(:,l));
                    numrow = 1; % numel of 1d array
                    notAllWhite = updown(imgSz,notAllWhite,sumrow,numrow);
                    if notAllWhite > thrW
                        rightbound = l+dl;
                        break
                    end
                end
        end      
    end    
%     rect = [leftbound,imgSz(1)+1-lowerbound,rightbound-leftbound,lowerbound-upperbound ];
    rect = [leftbound,upperbound,rightbound-leftbound,lowerbound-upperbound ];
    img2{i} = img{i}(max([upperbound,1]):min([lowerbound,imgSz(1)]),...
                                   max([leftbound,1]):min([rightbound,imgSz(2)]),:);
    if SaveInplace
        imwrite(img2{i},paths{i});
    end
%     imcrop(img{i},rect) ;
end

end

function imgSz=increseDim(imgSz)
    if length(imgSz)==2
        imgSz = [imgSz,1];
    end
end

function notAllWhite = updown(imgSz,notAllWhite,sumrow,numrow)
    if sumrow < 255*imgSz(3)*imgSz(numrow)
        notAllWhite = notAllWhite +1;
    else
%         notAllWhite = notAllWhite - 1;
    end

end
