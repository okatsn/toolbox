function [] = keepPlotRatio(ax,setratio2,varargin)
% ax = gca;
% setratio2 = 0.6;
% to be extended.
set(ax,'XLim',[ax(1).Children.XData(1),ax(1).Children.XData(end)]); %set XLim to the 1st timeseries.

for l = 1:length(ax)
    ax(l).Position(3) = setratio2;
end
end

