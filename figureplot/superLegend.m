function [H,plt] = superLegend(legend_cell,plot_options,varargin)
%


% NameOnly_cell = {'legend'};

TextOption0 = {}; %{'VerticalAlignment','Top'};% 'FontSize',14,'FontWeight','Bold','HorizontalAlignment','Center',
% TextPosition = {0,0};
AxesPosition = [0.2,0.6,0.2,0.15];


% [Results2,varargin2] = inputParser2(varargin,NameOnly_cell);

% p.KeepUnmatched = true;
p = inputParser;
addParameter(p,'AxesPosition',AxesPosition);
% addParameter(p,'TextPosition',TextPosition);
addParameter(p,'TextProperties',{});
addParameter(p,'IsMarker',0); % 0, 1, or [1,0,0,1,...] to identify to plot a single point or a line.
addParameter(p,'Interspace',0.05); % interspace between text and marker (line)
addParameter(p,'LineLength',0.17); % length of line before the text
parse(p,varargin{:});
IsMarker = p.Results.IsMarker;
TextOption = p.Results.TextProperties;
% TextPosition = p.Results.TextPosition;
AxesPosition = p.Results.AxesPosition;
text_marker_space = p.Results.Interspace;
line_length = p.Results.LineLength;
H = axes('Position',AxesPosition);
H.Color = 'w';
H.XColor = 'k';
H.YColor = 'k';
H.Box = 'on';

% if isempty(TextOption)
%     TextOption = TextOption0;
% else
    TextOption = [TextOption0,TextOption];
% end


NoD = numel(plot_options);
IsMarker1 = zeros(1,NoD);
if isequal(IsMarker,1)
    IsMarker1(:) = 1;
elseif isequal(IsMarker,0)
    % do nothing
else
    IsMarker1 = IsMarker;
end

if NoD == numel(legend_cell) &&NoD == numel(IsMarker1)
    % good, do nothing
else
    error("The number of elements of legend_cell, plot_options and 'IsMarker' array has to be identical.");
end

iscell_ind = cellfun(@iscell, legend_cell);
lgds = legend_cell;
lgds(~iscell_ind) = cellfun(@(x) {x}, legend_cell(~iscell_ind),'UniformOutput',false); 
% e.g. to make {{'lgd1-line1','lgd1-line2'},'lgd2-only1line'} become {{'lgd1-line1','lgd1-line2'},{'lgd2-only1line'}}
lgds_lines = cellfun(@numel,lgds); % to count how many lines in each legend
total_lines = sum(lgds_lines);

% lgds = cellfun(@(x) {x}, legend_cell(~iscell_ind))
% b= [legend_cell{iscell_ind}, legend_cell{}];



H.YTick = linspace(0,1,total_lines+2);
YTicks = H.YTick(2:end-1);
YTicks = fliplr(YTicks);
% YTicks = YTicks + 0.5*YTicks(end); % shift half interspace up .
H.XTick = 0:0.1:1;

plt = gobjects(1,NoD);
txt = cell(1,NoD);
YTick_id = 1;
for i = 1:NoD
    
    options_i = plot_options{i};
    ismk_i = IsMarker1(i);
    y = [YTicks(YTick_id), YTicks(YTick_id)];
    x = [0.05, 0.05 + line_length];    
    x_text = x(end)+text_marker_space;
    if ismk_i % plot a point instead of a short line
        x = mean(x);
        y = y(1);
     end
    
    plt(i) = plot(x,y,options_i{:});
    hold on
    
    txt{i} = text(x_text,  y(1), legend_cell{i}, TextOption{:});
    
    YTick_id = YTick_id + lgds_lines(i);
end

H.XTickLabel = {};
H.YTickLabel = {};
H.TickLength = [0;0];
H.XLim = [0, 1];
H.YLim = [0, 1];
end

