function [Pt_x,Pt_y] = rand2x(XLimits,YLimits,numPt)
% Create a set of points randomly distributed between the area specified by
% XLimits and YLimits. 
Pt_x = XLimits(1) + diff(XLimits)*rand(numPt,1);
Pt_y = YLimits(1) + diff(YLimits)*rand(numPt,1);
end

