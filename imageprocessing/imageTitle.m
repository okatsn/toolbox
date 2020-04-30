function [img_with_title] = imageTitle(img_or_titlesize,titlestring)
% Input:
%     img_or_titlesize:
%         one image array of type i.e. uint8
%     titlestring:
%         string of the title. Usage is like text(x,y,titlestring)
%         e.g. titlestring = 'Super big title';
%         e.g. titlestring = {'Super big title','2nd line'};
% Output:
%     an image array with a super title


ftmp = figure;


AxesPosition = [0,0,1,1];
titleheightfraction = 0.05;
h0 = 100;

switch class(img_or_titlesize)
    case {'uint8','uint16','uint32','uint64'}
        img0 = img_or_titlesize;
        w = size(img0,2);
        h = titleheightfraction*size(img0,1);
        wh_ratio = w/h;
        
    otherwise
        error('Under construction...');
        
end

if ischar(titlestring) || isStringScalar(titlestring)
    titlestring = {titlestring};
end

if ischar(titlestring) || isStringScalar(titlestring)
    titlestring = {titlestring};
end
NLines = length(titlestring);
h1 = round(h0*NLines*0.85);
w1 = round(h0*wh_ratio);

fx = gcf;
fx.Position = [0,0,w1,h1];
H = axes('Position',AxesPosition);
H.Color = 'none';
H.XColor = 'none';
H.YColor = 'none';

H.XLim = [0,1];
H.YLim = [0,1];
TextOption = {'FontSize',40,'FontWeight','Bold','HorizontalAlignment','Center','VerticalAlignment','Bottom'};
TextPosition = {0.5, 0.1};
text(TextPosition{:},titlestring,TextOption{:});

imtitle = fig2im(ftmp);
[~,img_with_title] = im2im({imtitle{1};img0});
% imshow(img_with_title);

close(ftmp);

end

