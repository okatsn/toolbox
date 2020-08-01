function movelegendto(legend_handle,to_where,varargin)
% move the legend to a place on the figure
% to_where: e.g. 'top' or 'bottom'
% shift = [xshift,yshift]: e.g. [0, 0.1]
%
% usage: 
% movelegendto(legend_handle,to_where)
% movelegendto(legend_handle,to_where,shift)

error('this function is deprecated. use setPosition instead.')
if nargin > 2
    shift = varargin{1};
else
    shift = [0,0];
end

legend_handle.Units = 'normalized';
pos0 = legend_handle.Position;
pos1 = pos0;

pos1(1) = 0.5 - 0.5*pos0(3) + shift(1); % xstart at middle
switch to_where
    case 'top' % middle top
        pos1(2) = 1 - pos0(4) + shift(2); % ystart        
    case 'bottom' % middle bottom
        pos1(2) = 0 + shift(2); % ystart
    otherwise
        error('unsupported position name.');
end
legend_handle.Position = pos1;
end

