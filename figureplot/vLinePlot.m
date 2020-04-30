% add multiple vertical line to plot
% example : vLinePlot([1,2,3],gca_2,'LineProperties',{'Color','r'});
function [Ax1,varargout] = vLinePlot(add_line_at_X,varargin)
p = inputParser;
default_config_of_line = {}; %{'Color','g'};
default_config_of_text = {};
% addRequired(p,'add_line_at');
addOptional(p,'Axes',gca);
addParameter(p,'LineProperties',default_config_of_line);
addParameter(p,'TextProperties',default_config_of_text);
addParameter(p,'CommonProperties',default_config_of_text);
addParameter(p,'DrawNow',false);

addParameter(p,'text',0);
addParameter(p,'TextShift',[0,-0.1]); % shift text [xshift, yshift]. xyshift should range in [0,1] (the portion of xylim);
% addParameter(p,'Color','g');
% addParameter(p,'yscale_','linear');
% addParameter(p,'LineStyle','-');
parse(p,varargin{:});
rslt = p.Results; 
Ax1 = rslt.Axes;
text_string = rslt.text; text_property = rslt.TextProperties; line_property = rslt.LineProperties;
common_config = rslt.CommonProperties;
TextShift = rslt.TextShift;
DrawNow = rslt.DrawNow;
% clr = rslt.Color;

text_property = [text_property,common_config];
line_property = [line_property,common_config];

% assignin('base','vararginVL',varargin);
% assignin('base','line_property',line_property);
% assignin('base','Ax1',Ax1);


switch class(text_string)
    case 'double'
        % do not text
        text_cell = 0;
    case 'cell'
        text_cell = text_string;
    case 'char'
        text_cell = cellfun(@(x) text_string,cell(size(add_line_at_X)),'UniformOutput',false);
    otherwise
        error('incorrect input of text string.');
end


NoX = numel(add_line_at_X);

for k = 1:numel(Ax1)
%     assignin('base','k',k);
    Y_range = Ax1(k).YLim;
    
    for i = 1:numel(add_line_at_X)
        X = add_line_at_X(i);
        line([X X],Y_range,'Parent',Ax1(k),line_property{:});
        if DrawNow
            drawnow;
        end
    end
    
    if ~isequal(text_cell,0) % if there is text.
        at_Y = Y_range(2) + TextShift(2)*diff(Y_range);
        dx = TextShift(1)*diff(Ax1(k).XLim);
%         at_Y = Y_range(2);
        for j = 1:NoX
            at_X = add_line_at_X(j) + dx;
            text(at_X, at_Y,text_cell{j},'Parent',Ax1(k),text_property{:});
        end
    end
    
    set(Ax1(k),'YLim',Y_range);
    
end


end

