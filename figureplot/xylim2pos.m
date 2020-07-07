function [pos] = xylim2pos(varargin)
% Convert the range in format XLim and YLim in to the format for
% (...,'Position', pos).
% x_lim: 1 by 2 numeric array specifying [x_min, x_max]
% y_lim: 1 by 2 numeric array specifying [y_min, y_max]
% ax: graphic handle containing field 'XLim' and 'YLim'.
% pos: 1 by 4 numeric array specifying [x_min, y_min, x_width, y_height]

if nargin == 1
    ax = varargin{1};
    x_lim = ax.XLim;
    y_lim = ax.YLim;
elseif nargin == 2
    x_lim = varargin{1};
    y_lim = varargin{2};
end

pos = [x_lim(1),y_lim(1),diff(x_lim),diff(y_lim)];
end

