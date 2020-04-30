function [ij] = xy2ij(im_or_mn,xy,varargin)
% return the index [i,j] for a 2d-array of size [m,n] that contains the point xy.
switch class(im_or_mn)
    case 'matlab.graphics.primitive.Image' % array2d = imagesc(TwLonLim,TwLatLim,C);
        xlimits = im_or_mn.XData;
        ylimits = im_or_mn.YData;
        mn = size(im_or_mn.CData);
    case 'double'
        xlimits = varargin{1};
        ylimits = varargin{2};
        mn = im_or_mn;
end
xticks = linspace(xlimits(1),xlimits(2),mn(2)); % tick at the center of cell
yticks = linspace(ylimits(1),ylimits(2),mn(1));
[nearest_idx_x,value_1] = nearest1d(xticks,xy(1));
[nearest_idx_y,value_1] = nearest1d(yticks,xy(2));
ij = [nearest_idx_y,nearest_idx_x];
end

