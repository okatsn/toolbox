function [graphicObject] = setPosition(graphicObject,varargin)
% set the position of matlab graphic objects.
% graphic object can be
%    1. legend ('matlab.graphics.illustration.Legend')
%    2. xlabel or ylabel ('matlab.graphics.primitive.Text')
% Example 1.
%     lgd = legend(...);
%     setPosition(lgd); % move the legend to the middle top
%     setPosition(lgd,'bottom'); % move the legend to the middle bottom
%     setPosition(lgd,[0.02, 0.01],'bottom'); % shift after moving to bottom
% Example 2.
%     subplot(...);
%     ...
%     xl = xlabel(...); % label only on the last subplot
%     yl = ylabel(...); % label only on the last subplot
%     setPosition(xl,'bottom'); % move xlabel to the most middle bottom axes.
%     yl = setPosition(yl,'left');% move xlabel to the most middle left axes.
%     setPosition(yl,[0.02, 0.01]); % shift after moving to the left


moveto = 'nothing';
shiftto = [0, 0];
objclass = class(graphicObject);

if nargin > 1
    if ischar(varargin{end})
        moveto = varargin{end};
        if nargin > 2
            shiftto = varargin{1};
        end
    else
        shiftto = varargin{1};
    end
    
end
Unit0 = graphicObject.Units;
graphicObject.Units = 'normalized';

Pos0 = graphicObject.Position;
Pos1 = Pos0;


switch objclass
    case 'matlab.graphics.illustration.Legend'
        objwidth = Pos0(3);
        objheight = Pos0(4);
        switch moveto
            case 'top'
                Pos1(1) = 0.5 - objwidth/2;  % new xstart
                Pos1(2) = 1-objheight; % new ystart
            case 'bottom'
                Pos1(1) = 0.5 - objwidth/2 ;  % new xstart
                Pos1(2) = 0; % new ystart
        end
    case 'matlab.graphics.primitive.Text' % for x, ylabel
            originalParent = graphicObject.Parent;
            grandParent = graphicObject.Parent.Parent;
            uncles = grandParent.Children.findobj('Type','axes');            
            lenuncles = length(uncles);
            unclePositions = NaN(lenuncles,4);
            for i = 1:lenuncles
                unclePositions(i,:) = uncles(i).Position;
            end
            [minval,minind] = min(unclePositions,[],1);
            midval = median(unclePositions,1);
            minpos = repmat(minval,lenuncles,1);
            midpos = repmat(midval,lenuncles,1);
            diffminpos = abs(unclePositions(:,1:2) - minpos(:,1:2));
            diffmidpos = abs(unclePositions(:,1:2) - midpos(:,1:2));
        switch moveto
            case 'left' % copy object to the middle-left axes.
                % the middle left one is expected to have the smallest xstart
                % (closest to the mean) and ystart closest to the median.
                [~,ind] = min(sum([diffminpos(:,1),diffmidpos(:,2)],2)); 
                graphicObject2 = copyobj(graphicObject,uncles(ind));
            case 'bottom'
                [~,ind] = min(sum([diffmidpos(:,1),diffminpos(:,2)],2)); 
                graphicObject2 = copyobj(graphicObject,uncles(ind));
        end
        delete(graphicObject);
        graphicObject = graphicObject2;
    otherwise
        error("graphic object '%s' is not supported by this function yet",objclass);
end
Pos1(1:2) = Pos1(1:2) + shiftto; 
graphicObject.Position = Pos1;
graphicObject.Units = Unit0; % restore the original setting.
end

