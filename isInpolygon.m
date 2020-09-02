function [inBg, insideRatio] = isInpolygon(xBg,yBg,xv,yv,varargin)
% Determine if points are in polygon(s).
% To calculate the area of only one polygon, use 'polyarea' instead,
% 'isInpolygon' uses 'inpolygon' and is 500 times slower than 'polyarea'.
% Input: 
%     xBg, xBg: the (background) points to be determined whether they 
%               are in the polygon(s) or not.
% 
%     xv, yv: vertices of the polygon(s), must be N by 1 or N by M, 
%             N is the number of vertices, and
%             M is the number of polygons
%        
% Output:
%     inBg: indices indicating whether the points (xBg,yBg) is inside the polygon.
%          It has the same size as xBg and yBg.
%     insideRatio: The proportion of inside points sum(inp)/length(xBg);
% 
% Example:
%     randXY = rand(5000,2);
%     xBg = randXY(:,1);
%     yBg = randXY(:,2);
% 
%     [xv1,yv1] = circleLine(0.3,0.5,0.2);
%     [xv2,yv2] = circleLine(0.7,0.5,0.3);
%     [xv3,yv3] = circleLine(0.5,0.2,0.2);
%     xv = [xv1,xv2,xv3];
%     yv = [yv1,yv2,yv3];
% 
%     [inBg, insideRatio] = isInpolygon(xBg,yBg,xv,yv)
%     figure; 
%     plot(xv(:),yv(:));
%     hold on;
%     plot(xBg,yBg,'o'); 
%     plot(xBg(inBg),yBg(inBg),'*');

numPoly = size(xv,2);
if numPoly>1
    nansplitter = NaN(1,numPoly);
    xv = [xv;nansplitter];
    yv = [yv;nansplitter]; 
    % split the vertices for different polygon by NaN. See doc inpolygon
end

inBg = inpolygon(xBg,yBg,xv(:),yv(:));
insideRatio = sum(inBg,'all')/length(xBg(:));


end

