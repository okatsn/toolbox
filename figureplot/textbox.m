function [outputArg1,outputArg2] = textbox(varargin)
% 1. use this just like text()
% 2. Name-Value pairs is the same as rectangle()
% 3.
%     ...,'ModifyTextExtent', [0.1, 0.1, 0.1, 0.1]); % expand the box's four boundaries by 0.1
%     ...,'ModifyTextExtent', 0.1); % the same as above
%     ...,'ModifyTextExtent', [0.1, -0.1]); % expand left and right boundaries by 0.1; up and down by -0.1

if isa(varargin{1}, 'matlab.graphics.axis.Axes')
    ax = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end

first_is_text = cellfun(@(x) ischar(x)||isStringScalar(x),varargin);
text_id = find(first_is_text,1);
pos = varargin(1:text_id-1);
string1 = varargin{text_id};
varargin2 = varargin(text_id+1:end);

p = inputParser;
p.KeepUnmatched = true;
addParameter(p,'ModifyTextExtent',0); % e.g. [0.1, 0.1, 0.1, 0.1] will expand the box's boundaries by 0.1
addParameter(p,'FaceColor','none'); % for rectangle
addParameter(p,'EdgeColor',[0 0 0]); % for rectangle
addParameter(p,'LineWidth',0.5); % for rectangle
addParameter(p,'LineStyle','-'); % for rectangle
parse(p,varargin2{:});

to_expand = p.Results.ModifyTextExtent;
LineStyle = p.Results.LineStyle;
LineWidth = p.Results.LineWidth;
EdgeColor = p.Results.EdgeColor;
FaceColor = p.Results.FaceColor;

if length(to_expand) == 1
    to_expand1 = zeros(1,4);
    to_expand1(:) = to_expand;
elseif length(to_expand) == 4
    to_expand1 = to_expand;
elseif length(to_expand) == 2
    to_expand1 = reshape([to_expand;to_expand]',1,4);
end
% if to_expand == 0. do nothing
varargin3 = struct2namevaluepair(p.Unmatched);

t = text(pos{:},string1,varargin3{:});
tmp = to_expand1.* [-1,-1,1,1];
to_expand2 = tmp + [0,0,to_expand1(1:2)];
textboxpos = t.Extent + to_expand2;
r = rectangle('Position',textboxpos,...
    'LineStyle',LineStyle,'LineWidth',LineWidth,'EdgeColor',EdgeColor,'FaceColor',FaceColor);
ax.Children = [ax.Children(2);ax.Children(1);ax.Children(3:end)]; % move rectangle to lower level.

end

