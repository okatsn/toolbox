function [ax_1,plot_1,rect_0] = zoomPlot(ax_0,xrange,varargin)
% 'PlotNext': Copy ax_0 onto axes ax_1 (or the current graphic handle, gca), 
%             and zoom according to xrange by setting XLim and YLim of ax_1.
% 'PlotRectangle': rectangle on ax_0 according to the XLim and YLim of ax_1.

if length(xrange)~=2
    error('1st input argument must be a two-element array specifying the x-range to zoom.');
end

p = inputParser;
addParameter(p,'PlotRectangle',{});
addParameter(p,'PlotNext',false);
parse(p,varargin{:});

plotRect = p.Results.PlotRectangle;
ax_1 = p.Results.PlotNext;


plot_0 = ax_0.Children;

typelist = plot_0.get('type');
if ~iscell(typelist)
    typelist = {typelist};
end

Lia = ismember(typelist,{'rectangle'});
plot_0_no_rectangle = plot_0(~Lia); % do not copyobj of type 'rectangle'


% calculate proper YLim
ylim_1 = [];
for i = 1:length(plot_0_no_rectangle)
    ghandle_i = plot_0_no_rectangle(i);
    if strcmpi(ghandle_i.get('type'),'patch')
        % do not consider object of 'patch'
        continue
    end
%         if any(ismember({'line'},ghandle_i.get('type'))) 
        % only the graphic handle of type 'line' (maybe there are other) 
        % has field XData/YData
        ind2inview = ghandle_i.XData > min(xrange) & ghandle_i.XData < max(xrange);
        Y_in = ghandle_i.YData(ind2inview);
        ylim_1 = [ylim_1,max(Y_in),min(Y_in)];
%         end
end
ylim_1_1 = [min(ylim_1),max(ylim_1)];
yrange = ylim_1_1 + diff(ylim_1_1)*[-0.03,0.03];

do_plotNext = ~isequal(ax_1,false);
% zoom plot onto ax_1
if do_plotNext
    if ~isgraphics(ax_1)
        ax_1 = axes; % new axes
    end
    plot_1 = copyobj(plot_0_no_rectangle,ax_1);
else
    ax_1 = struct();
    plot_1 = gobjects(0); % return an empty graphic object
end

ax_1.XLim = xrange;
ax_1.YLim = yrange;

if ~isempty(plotRect)
    rect_0 = rectangle(ax_0,'Position',xylim2pos(ax_1),plotRect{:});
%     vRectPlot(xrange,'rectangleProperties',plotRect,'Axes',ax_0);
else
    rect_0 = [];
end

end

