function [Cx,Cy] = circleLine(x,y,r,varargin)
% Input:
%     [Cx,Cy] = circleLine(x,y,r) % of draw a circle centered at x, y with
%     radius r.
% 
%     [Cx,Cy] = circleLine(x,y,r,1000) % of total points of 100
% 
%     theta = 0:0.5:2*pi;
%     [Cx,Cy] = circleLine(x,y,r,theta); % create points at specific angles.
% 
% Output:
%     figure; plot(Cx,Cy);

if nargin>3
    firstArg = varargin{1};
    if length(firstArg) == 1 
        numPt = firstArg;
        theta = linspace(0,2*pi,numPt);
    else
        theta = firstArg;
    end
else
    numPt = 100; % default
    theta = linspace(0,2*pi,numPt);
end

Cx = r*cos(theta)+x;
Cy = r*sin(theta)+y;
Cx = Cx(:);
Cy = Cy(:);
end

