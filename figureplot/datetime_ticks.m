function [ticks,tickLabels,varargout] = datetime_ticks(datenum_or_datetime,t_Format,N,YorMorD,varargin)
% [ticks,tickLabels,datenum0] = datetime_ticks(t_list,t_Format,every_N,YorMorD)
%
% e.g. [ticks,tickLabels] = datetime_ticks(datenumList,'yyyy-mm',1,'months') 
%         produces ticks(datenum) and tickLabels(cell array) every 1 month 
%         for set(gca,'XTickLabel',tickLabels,'XTick',ticks);
%
% e.g.2. [ticks,tickLabels,x0] = datetime_ticks(datetimeList,t_Format,N,YorMorD)
%             This also export x0 for such as imagesc(x0,y,array_2d);
p = inputParser;
addParameter(p,'GraphicAxes',0);
parse(p,varargin{:});
rslt = p.Results;
GraphicAxes = rslt.GraphicAxes;

[~,n]=size(datenum_or_datetime);

if n~=1 %make sure the input data is m*1 array.
    datenum_or_datetime = datenum_or_datetime';
end

if isdatetime(datenum_or_datetime) %if input is datetime
    datenum0 = datenum(datenum_or_datetime);
    datetime0 = datenum_or_datetime;
    outputdatetime = true;
else                                                                % if input is datenum
    datenum0 = datenum_or_datetime;
    datetime0 = datetime(datenum_or_datetime,'ConvertFrom','datenum');
    outputdatetime = false;
end

switch YorMorD
    case {'years','Years'}
        every_ = @calyears;
    
    case {'months','Months'}
        every_ = @calmonths;
        
    case {'days','Days'}
        every_ = @caldays;

    case {'hours','Hours'}
        every_ = @hours;

    case {'seconds','Seconds'}
        every_ = @seconds;
end
        
datetime1 = [datetime0(1):every_(N):datetime0(end)]';
datenum1 = datenum(datetime1);

if outputdatetime
    ticks = datetime1;
else
    ticks = datenum1;
end
% 
tickLabels = datestr(datetime1,t_Format);

if nargout == 3
    varargout{1} = datenum0;
end

% if ~isequal(GraphicAxes,0)
%     try
%         set(GraphicAxes,'XTickLabel',tickXLabels,'XTick',ticks);
%     catch ME
%         set(GraphicAxes,'XTickLabel',tickXLabels,'XTick',datetime(ticks,'ConvertFrom','dateNum'));
%     end
%     ax.XLabel.Rotation=45; % rotate YLabel to horizontal
end

