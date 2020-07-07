function  r = vRectPlot(plotAt,varargin)
% Plot vertical rectangles.
% input (plotAt) has to be one of the followings:
%         1. N by 2 numeric array, where N must >1. The first column is the
%         left boundary of the rectangle; the second column the span.
%             E.g. [1, 2; 1.5, 2] will plot two rectangles with left edges at 1 and 1.5, and both width 2.
%         2. N-elements numeric array, where N must be even.
%             E.g. [1,2,5,6] will plot two rectangles. The the first rectangle spans from x=1 to x =2; the second, from x=5 to x =6.

p = inputParser;
rectangle_name_value_pairs = {}; %e.g. {'Curvature',0.2};

addOptional(p,'Axes',gca);
addParameter(p,'rectangleProperties',rectangle_name_value_pairs);
% addParameter(p,'DrawNow',false);

parse(p,varargin{:});
rslt = p.Results; 
ax = rslt.Axes;
% DrawNow = rslt.DrawNow;
rectProps = rslt.rectangleProperties;
parse(p,varargin{:});

if isequal(rectProps,1)
    rectProps = rectangle_name_value_pairs; % then use default
end

Y_range = ax.YLim;
ystart = Y_range(1);
yspan = Y_range(2) - Y_range(1);

[SzDim1,SzDim2] = size(plotAt);
if SzDim2 == 2 && SzDim1 >1 % N by 2 array
    xstart = plotAt(:,1);
    xspan = plotAt(:,2);
elseif  SzDim2==1 ||  SzDim1 ==1
    if rem(length(plotAt),2) ~= 0
        error('The numberof  positions of the rectangles is odd. It has to be even since every rectangle has two side.');
    end
    xstart = plotAt(1:2:end);
    xspan = plotAt(2:2:end) - xstart;
end

nloops = length(xstart);
r = gobjects(nloops);
for i = 1:nloops
%     try
    r(i) = rectangle(ax,'Position',[xstart(i), ystart, xspan(i), yspan],rectProps{:});
%     catch ME
%         disp('');
%     end
    hold on
end
    
end

