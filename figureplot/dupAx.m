function [ax2] = dupAx(ax1,varargin)
% e.g. duplicate Y axis on the left (including label) to the right sides.
% e.g. ax1 = gca; dupAx(ax1) %
%
expectedInput = {'X','x','Y','y','XY','xy'};
valid_ft = @(x) any(validatestring(x,expectedInput));
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
% valid10 = @(x) (x==1) || (x==0);
validVec = @(x) isnumeric(x) && isequal(size(x),[1,2]);
p = inputParser;
% Warning, function must have varargin if addParameter is used. 
addParameter(p,'Duplicate','y',valid_ft);      
addParameter(p,'Shift',0,validVec);
% varargin{:} must be parsed otherwise parameter will always remains default value.
parse(p,varargin{:});  
rslt = p.Results;
caseXY = rslt.Duplicate;
doShift = rslt.Shift;


switch caseXY
    case {'X','x'}
        warning('under construction, do nothing');
        
    case {'Y','y'}
        ax_input = {'XTick',[],'YTickLabel',ax1.YTickLabel,'YTick',ax1.YTick};

end
ax1Pos = get(ax1,'Position');
if isequal(doShift,0)
    ax2Pos = ax1Pos;
else
    ax2Pos = ax1Pos + [doShift,0,0];
end


ax2=axes('Position',ax2Pos,'YAxisLocation','right','Color','none',ax_input{:});
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;
ax2.YDir = ax1.YDir;
ax2.YScale = ax1.YScale;
ax2.XScale = ax1.XScale;
ax2.YColor = ax1.YColor;
ax2.XColor = 'none';
ax2.YLabel.Color = ax1.YLabel.Color;




% yaxis_right = axes('Position',get(gca1,'Position'),'Color','none','XTick',[],'YAxisLocation','right');
% linkaxes([gca1 yaxis_right],'xy');
end

