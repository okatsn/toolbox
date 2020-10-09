function [targetAxes] = adjPlot(varargin)
% Adjust the plot. E.g. Set line width, font size at once.
% if there is an input matlab.graphic object, it has to be the first
% argument

class1Arg = class(varargin{1});
subplotTitle = gobjects(0); % empty graphic objects.

%% Default parameters
dem = 2;
Settings = {'thicker','larger','noticklabel','xtickfont','set1','set2','set3'};
warningmsg = 'Empty graphic objects.';
setbox = -1;
FontSz = 12;
% FontName = 'Noto Sans CJK TC Regular'; % use listfonts in command window to see the options
% FontName = 'Helvetica';
FontWeight = 'normal';% either normal or bold
LineWidth = 1.6;

%%
r = inputParser2(varargin,Settings);
switch class1Arg
%     case 'cell'
        
    case 'matlab.graphics.axis.Axes'
        targetAxes = varargin{1};
        
        targetLine = find_target_line(targetAxes);
    case 'matlab.graphics.chart.primitive.Line'
        targetLine = {varargin{1}};
    case 'matlab.ui.Figure' % that is equivalent to gcf
        targetAxes = findobj(varargin{1},'type','axes');
%         targetLine = findobj(varargin{1},'type','Line');
        targetLine = find_target_line(varargin{1});
    otherwise
        subplotTitle = findobj(gcf,'type','subplottext');
        targetAxes = findobj(gcf,'type','axes');
%         targetLine = findobj(gcf,'type','Line');
        targetLine = find_target_line(gcf);
end




if r.set1
    r.thicker = true;
    r.larger = true;
    FontSz = 14;
    FontWeight = 'normal';% either normal or bold
    LineWidth = 1.5;
    setbox = 1.5;
    r.xtickfont = true;
    tickfontSz = 8;
end




if r.set2
    r.thicker = true;
    r.larger = true;
    FontWeight = 'normal';% either normal or bold
    LineWidth = 1.5;
    setbox = 1.5;
end

if r.noticklabel
%     warning('This function is not available now.')
end

if r.thicker %Line and Box
    if ~isempty(targetLine) 
        for i = 1:length(targetLine)
                set(targetLine{i},'LineWidth', LineWidth);
        end
    else
       warning('No targetLine.');
    end
    if ~isequal(setbox,-1)
        set(targetAxes,'LineWidth',setbox);
    end
end

if r.larger %Font
    if ~isempty(targetAxes)
        set(targetAxes,'FontSize',FontSz ,'FontWeight',FontWeight); % ,'FontName',FontName
    else
        warning(warningmsg);
    end
    if ~isempty(subplotTitle)
        set(subplotTitle,'FontSize',FontSz+dem)
    end
end

if r.xtickfont
    xAx = get(targetAxes,'XAxis');
    if isa(xAx,'cell')
        for i = 1:length(xAx)
            set(xAx{i},'FontSize',tickfontSz)
        end
    else
        set(xAx,'FontSize',tickfontSz)
    end
end


end

function targetLine = find_target_line(targetAxes)
linetypes = {'Line','errorbar'};
targetLine = {};

for i = 1:length(linetypes)
    obj = findobj(targetAxes,'type',linetypes{i});
    if ~isempty(obj)
        targetLine = [targetLine,{obj}];
    end
end
end
