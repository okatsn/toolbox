function [axes2] = copyPlot(axes1,gcf1,varargin)
% copy axes1 = gca (or axes1 = plot, etc.) to a figure (gcf1=gcf or figure)
% input:
%     axes1: the graphic handle to be copied
%     gcf1: the figure to be pasted
% 
% parameter: 
%     ToSubplot: the graphic handle in destination. this handle will be deleted after copy-paste is complete.
% e.g. 
%     ax = plot(x,y);
%     gcf1 = figure;
%     ax_tmp = subplot(4,2,[2,4]); % empty axes, just for the re-Position for the plot to paste.
%     copyPlot(ax,gcf1,'ToSubplot',ax_tmp);

p = inputParser;
% addRequired(p,'axes1');
% addRequired(p,'gcf1');
addParameter(p,'ToSubplot',false);
parse(p,varargin{:});
r = p.Results;
% axes1 = r.axes1;
% gcf1 = r.gcf1;
subplot1 = r.ToSubplot;

% clssbp = class(subplot1);
if ~isa(subplot1,'logical')
    if ~isa(subplot1,'matlab.graphics.axis.Axes')
        warning('ToSubplot have to be matlab.graphics.axis.Axes. e.g. ToSubplot = subplot(2,1,1);. Please try again.');
        return
    else % not logical (not default), and is axes
        ax_tmp = subplot1;
        subplot1 = true;
    end
end

if subplot1
    axes1.Position = ax_tmp.Position;
end
copyobj(axes1,gcf1);


try
    delete(ax_tmp);
    axes2 = gca;
end


end

