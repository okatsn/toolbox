function  patch_handle = vPatchPlot(plotAt,varargin)
% Plot vertical rectangles using patch().
% input (plotAt) has to be one of the followings:
%         1. N by 2 numeric array, where N must >1. The first column is the
%         left boundary of the rectangle; the second column the span.
%             E.g. [1, 2; 1.5, 2] will plot two rectangles with left edges at 1 and 1.5, and both width 2.
%         2. N-elements numeric array, where N must be even.
%             E.g. [1,2,5,6] will plot two rectangles. The the first rectangle spans from x=1 to x =2; the second, from x=5 to x =6.

p = inputParser;
rectangle_name_value_pairs = {}; %e.g. {'Curvature',0.2};

addOptional(p,'Axes',gca);
addParameter(p,'OtherProperties',rectangle_name_value_pairs);
addParameter(p,'Color',[0.3569, 0.7569, 0.9882]); % the C in patch(X,Y,C);
% addParameter(p,'DrawNow',false);

parse(p,varargin{:});
rslt = p.Results; 
ax = rslt.Axes;
% DrawNow = rslt.DrawNow;
rectProps = rslt.OtherProperties;
patch_color = rslt.Color;

Y_range = ax.YLim;
ystart = Y_range(1);
yspan = Y_range(2) - Y_range(1);



[SzDim1,SzDim2] = size(plotAt);
if SzDim2 == 2 && SzDim1 >1 % N by 2 array
    error('N by 2 input may be supported in the future, but not now. ');
elseif  SzDim2==1 ||  SzDim1 ==1
    if rem(length(plotAt),2) ~= 0
        error('The numberof  positions of the rectangles is odd. It has to be even since every rectangle has two side.');
    end
    x_r12 = reshape(plotAt,2,[]);
    x_r34 = flipud(x_r12);
    xcoords = [x_r12;x_r34]; % There are 4 rows, with each column a set of x coordinates (4 points) of a rectangle.
    y_r12 =  Y_range(1)*ones(size(x_r12));
    y_r34 =  Y_range(2)*ones(size(x_r34));
    ycoords = [y_r12;y_r34]; % There are 4 rows, with each column a set of y coordinates (4 points) of a rectangle.
end



patch_handle = patch(ax,xcoords,ycoords,patch_color,rectProps{:});





    
end

