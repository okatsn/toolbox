function [Pt_x,Pt_y] = rand2(XLimits,YLimits,numPt,varargin)
% Create a set of points randomly distributed between the area specified by
% XLimits and YLimits.

lenvarargin = length(varargin);

if lenvarargin > 0
    if lenvarargin == 1
        dx = varargin{1};
        dy = dx;
    elseif lenvarargin == 2
        dx = varargin{1};
        dy = varargin{2};
    end
else
    Xwidth = diff(XLimits);
    Ywidth = diff(YLimits);
    maxwidth = max([Xwidth,Ywidth]);
    dx = maxwidth*1e-4;
    dy = dx;
end

xspace = XLimits(1):dx:XLimits(2);
yspace = YLimits(1):dy:YLimits(2);
lenXs = length(xspace);
lenYs = length(yspace);

xid = randi(lenXs,numPt,1);
yid = randi(lenYs,numPt,1);

Pt_x = xspace(xid);
Pt_y = yspace(yid);
end

