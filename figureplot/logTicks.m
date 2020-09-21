function ax = logTicks(ax,numelTicks,varargin)
% Force the number of ticks as numelTicks
if length(numelTicks) == 1
    numelTicks = [numelTicks,numelTicks];
end

[XTickLabelVal,XTickLabel] = logTicks_sub(ax.XLim,numelTicks(1));
ax.XTick = XTickLabelVal;
ax.XTickLabel = XTickLabel;
[YTickLabelVal,YTickLabel] = logTicks_sub(ax.YLim,numelTicks(2));
ax.YTick = YTickLabelVal;
ax.YTickLabel = YTickLabel;
end

function [XTickLabelVal,XTickLabel] = logTicks_sub(axLim,numelTick_i)
    innerXLimPow = ceilfloor(log10(axLim));
    tickInterv = ceil((diff(innerXLimPow)+1)/numelTick_i);
    XTickLabelValPow = innerXLimPow(1):tickInterv:innerXLimPow(2);
    XTickLabel = arrayfun(@num2str,XTickLabelValPow,'UniformOutput',false);
    XTickLabelVal = 10.^XTickLabelValPow;
end