function [catalog_F,varargout] = EQinRange(catalog,varargin)
% catalog_in_Rc = EQinRange(StLonLat,Rc,CWBcatalog,varargin)
% input: 
%     LatLon : [latitude,longitude] of a point P.
%     Rc: the radius (km)
%     catalog: earthquake CWBcatalog = loadSheet(filepath,'CWBcatalog');
%             catalog should be a N by 6 table, with: 
%             columns(VariableNames) 'time','Lon', 'Lat', 'Mc', 'Depth', 'Datetime'.
%             Use loadSheet.m to load catalog.
% output:
%     catalog_in_Rc = only earthquake events within radius Rc around point P.

warning('EQinRange() is deprecated. Use eventFilter() and plotEpicenter() instead');
errorStruct.identifier = 'Custom:Error';
valid10 = @(x) (x==1) || (x==0);
% validcell = @(x) iscell(x) && length(x) == 2;
NameOnly_cell = {'map','regular','filled'};
validPlotEpicenter = @(x) isequal(x,1)||isequal(x,0)||isa(x,'cell')||any(validatestring(x,NameOnly_cell));
% PlotEpicenter has to be 1 (plot on map), cell (custom options in plot) 
% or string ('map' or 'regular' using default options)

p = inputParser;
% addRequired(p,'catalog');
addParameter(p,'Radius',0); % {[Lat,Lon],[r0,r1]} or  {[Lat,Lon],[r1]} % r0=0 by default
addParameter(p,'Magnitude',0); % [LowerBound, UpperBound] of event magnitude.
addParameter(p,'TimeRange','default'); % [LowerBound, UpperBound] of event magnitude.
addParameter(p,'PlotVerticalLine',0);
addParameter(p,'PlotEpicenter',0,validPlotEpicenter);
addParameter(p,'EpicenterMarkerSize',999);
addParameter(p,'MagnitudeTag',0);
pm2 = 'ConsiderDepth'; addParameter(p,pm2,1,valid10);

% addParameter(p,'PlotVerticalLine',0);
% addParameter(p,'ConsiderDepth',0);
parse(p,varargin{:});
rslt = p.Results;
% latlon1 = rslt.LatLon;
% catalog = rslt.catalog;
conDep = rslt.ConsiderDepth;
Radius = rslt.Radius;
MagRange = rslt.Magnitude;
TimeRange = rslt.TimeRange;
ax = rslt.PlotVerticalLine;
PlotEpicenter = rslt.PlotEpicenter;
MagnitudeTag = rslt.MagnitudeTag;

MkSz = rslt.EpicenterMarkerSize;
if ~isequal(MkSz,999)
    error("'EpicenterMarkerSize' is deprecated. Use name-parameter pairs in 'PlotEpicenter'");
end

%% select by time
if strcmp(TimeRange,'default')
% disp('default time range')
% t0t1 = [catalog.DateTime(end),catalog.DateTime(1)];
% dt0 = t0t1(1);  dt1 = t0t1(2); %                                                                                      just for showing information
% do nothing
else
    try
        switch class(TimeRange)
            case 'double'
                dt0 = datetime(TimeRange(1),'ConvertFrom','datenum');
                dt1 = datetime(TimeRange(2),'ConvertFrom','datenum');
            case {'char','string'}
                A = regexp(TimeRange,'\d{8}','match');
                dt0 = datetime(A{1},'InputFormat','yyyyMMdd');
                dt1 = datetime(A{2},'InputFormat','yyyyMMdd');
            case 'datetime'
                dt0 = TimeRange(1);
                dt1 = TimeRange(2);
            otherwise
                errorStruct.message = 'TimeRange has to be a string, or 1 by 2  datetime/datenum array.';
                error(errorStruct)
        end
    catch ME
        warning("If input is 'double', it should be a 1 by 2 datenum array. e.g. [731510,737533]");
        warning("If input is string/char, format should be yyyymmdd. E.g. '20120101 to 20130202'. ");
        warning("If input is 'datetime', it should be a 1 by 2 datetime array.");
        rethrow(ME)
    end
    tidx = catalog.DateTime>= dt0 & catalog.DateTime<=dt1;
    catalog = catalog(tidx,:);
%     fprintf('User defined TimeRange: %s<t<%s  \n',datestr(dt0,'yyyymmdd'),datestr(dt1,'yyyymmdd'));
end
%% Select by Magnitude
if isequal(MagRange,0)
    MagRange = [MagRange, 13]; %                                                                                just for showing information
else
    MagRange = [MagRange, 13];% no events will larger than 13;
    midx = catalog.Mag> MagRange(1) & catalog.Mag<MagRange(2);
    catalog = catalog(midx,:);
end

%% Select by Radius
Depth = catalog.Depth;
LatLon2 = [catalog.Lat,catalog.Lon]; 
% faster to copy a certain variable from table before entering for loop.

switch class(Radius)
    case 'cell'
        ridx = [];
        RcRange = [0, Radius{2}]; % Radius{2} may be e.g. 15 or [5,15]
        Rc0 = RcRange(end-1);
        Rc1 = RcRange(end);
        latlon1 = Radius{1};      
        NoD = numel(catalog.DateTime);
        StHypDist = NaN(NoD,1);
%         fprintf('Center at: Latitude= %.2f; Longitude= %.2f \n',latlon1(1),latlon1(2));
        %                                                                                                                                     just for showing information
        
        switch conDep
            case 0
                for i = 1:NoD
                    [eqdist , ~]=lldistkm(latlon1,LatLon2(i,:));
                    % d1km: distance in km based on Haversine formula
                    if eqdist<Rc1 && eqdist>Rc0
                        ridx = [ridx i];
                        StHypDist(i) = eqdist;
                    end
                end
            case 1
                if Rc1>1000
                    warning('Beware that distance is NOT calculated in 3D space, i.e. If Rc or Depth is very large, results deviate.');
                    % to get the real distance between the two points on
                    % earth, you may refer to lla2ecef or sph2cart
                end
                for i = 1:NoD
                    arclendeg=distance('gc',latlon1,LatLon2(i,:));
                    arclenkm=deg2km(arclendeg);
                    eqdist=sqrt(arclenkm.^2+Depth(i).^2);
                    if eqdist<Rc1 && eqdist>Rc0
                        ridx = [ridx i];
                        StHypDist(i) = eqdist;
                    end
                end
        end
        catalog_F = catalog(ridx,:);
%         if nargout >1
%             varargout{1} = StHypDist;
%         end
    case 'double'
        if isequal(Radius,0) % if no input (= default)
%             Rc0 = 0;       Rc1 = 'infinite'; %                                                                            just for showing information
            catalog_F = catalog;
%             disp('Center and Radius not assigned.')
        else
            errorStruct.message = "Incorrect input parameter 'Radius'. It should be {[Lat,Lon],[r0,r1]}.";
            error(errorStruct)
        end
    otherwise
        errorStruct.message = "Incorrect class of input parameter 'Radius'.";
        error(errorStruct)
end

%% Plot (copied)

magtag  =~isequal(MagnitudeTag,0);
if isequal(ax,0)&&magtag
        ax = gca;
end

if isa(ax,'matlab.graphics.axis.Axes')
    TextProperties = {'BackgroundColor','white','Margin',0.1};
datelist_F=catalog_F.DateTime;

if magtag
    Mc_F=catalog_F.Mag;
    Mc_info = cellfun(@(Mi) sprintf('M_L=%.1f',Mi),num2cell(Mc_F),'UniformOutput',false);
    switch class(MagnitudeTag)
        case 'cell'
            TextProperties = [MagnitudeTag,TextProperties];
        case 1
            TextProperties = {'Rotation',45,'FontSize',9,'BackgroundColor','white','Margin',0.1};
    end
        
    
else
    Mc_info = '';
end

xm = {ax.XLim};
ym = {ax.YLim};
NoAx = numel(ax);
%     for j = 1:numel(ridx)
%         EQ = datelist_F(j);
%         for k = 1:NoAx%註h(1,3,5,7)為legend
%             ym=get(h(k),'YLim');% get(h(2),'YLim') 會是 [0 12]之類的; 
            vLinePlot(datelist_F,ax,'CommonProperties',{'Color','r'},'LineProperties',{'LineStyle','-'},...
                'TextProperties',TextProperties...
                ,'text',Mc_info);            
%             line([EQ EQ], ym{k} , 'Parent', ax(k),'Color','g');%註：x = [1 1]; y=[0 5]; line(x,y)會畫出在x = 1處，垂直直線高度範圍為0到5。
%             text(EQ, ym{k}(2),sprintf('M_L=%.1f',Mc_F(j)),'Parent', ax(k),'Color','r','VerticalAlignment','top')
%         end
%     end

    for k=1:NoAx
        set(ax(k),'xlim',xm{k});
        set(ax(k),'ylim',ym{k});
%         ax(k).Legend.String{2} = RcInfo;% remove extra legends
%         ax(k).Legend.String(3:end) = [];% remove extra legends
        %set(fig,'defaultLegendAutoUpdate','off'); Use this outside the figure instead.
    end
    
else
    if ~isequal(ax,0)
        errorStruct.message = sprintf('Parameter %s should be matlab.graphics.axis.Axes',pm1);
        error(errorStruct)
    end

end

%% Plot epicenter

if ~isequal(PlotEpicenter,0) && ~isempty(catalog_F)
%     ax2 = axes;
    
    Results = struct();
    for ri = 1:numel(NameOnly_cell)
       Results.(NameOnly_cell{ri}) = false; % Results.map = false; Results.regular = false;
    end
    
    MarkerSizes = [5,25]; % default value
    
    if isequal(PlotEpicenter,1) 
        % map plot with no custom options.
        customProperites = {};
        Results.map = true;
    else
        switch class(PlotEpicenter)
            case 'cell' 
                % e.g. {'map','filled','MarkerEdgeColor','r'} 
                % will give: Results.map =1; customProperites = {'filled','MarkerEdgeColor','r'}
                [Results,function_varargin2] = inputParser2(PlotEpicenter,NameOnly_cell);
                % remove 'map' or 'regular' first. The rest is
                % customProperites in scatterm or scatter.
                hot1 = flipud(hot);
                hot1(1:20,:) = []; % remove those too bright in the color bar.
                p2 = inputParser;
                p2.KeepUnmatched = true;
                addParameter(p2,'MarkerSize',5); % [a,b]; where marker size will be a + b*Magnitude.
                addParameter(p2,'MarkerFaceColor',hot1);
%                 addParameter(p2,'MarkerEdgeColor','none');
                
                parse(p2,function_varargin2{:});
                MarkerSize0 = p2.Results.MarkerSize;
                MarkerFaceColor = p2.Results.MarkerFaceColor;
%                 MkEdgeColor = p2.Results.MarkerEdgeColor;
                if length(MarkerSize0)==1
                    MarkerSizes(:) = MarkerSize0;
                elseif length(MarkerSize0)==2
                    MarkerSizes = MarkerSize0;
                else 
                    warning("[EQinRange] 'PlotEpicenter'>'MarkerSize' ignored because dimension is not legal.")
                end
                
                if Results.filled
                    customProperites = [{'filled'},namedargs2cell(p2.Unmatched)];
                else
                    customProperites = namedargs2cell(p2.Unmatched);
                end
                

            case 'char'
                Results.(PlotEpicenter) = true;
                customProperites = {};
            otherwise
                error("Input pararmeter 'PlotEpicenter' type error. This should not happen.");
        end

    end
    
    P1.MarkerFaceAlpha = 0.5;
    P1.MarkerType = 'p';
%     Property_list = fieldnames(P1);

    mkrsize = MarkerSizes(1) + (catalog_F.Mag)*MarkerSizes(2)*5;
    
    if size(MarkerFaceColor,1)==1 % only one color
        mkcolor = MarkerFaceColor;
    else
        mkcolor = catalog_F.Mag;
    end
    
%     if isfield(Results,'monocolor') && Results.monocolor == 1
%         mkcolor = 10*ones(size(catalog_F.Mag));
%         MarkerFaceColor(end,:) = [1,0,0];
%     else
%         mkcolor = catalog_F.Mag;
%     end

    if Results.regular % regular plot
        sct = scatter(catalog_F.Lon,catalog_F.Lat,mkrsize,mkcolor,customProperites{:});%,'filled');
    %     sct = scatter(ax2,catalog_F.Lon,catalog_F.Lat,mkrsize,mkcolor,customProperites{:});%,'filled');
        sct.Marker = P1.MarkerType;
    else % plot on map
        sct = scatterm(catalog_F.Lat,catalog_F.Lon,mkrsize,mkcolor,...
            P1.MarkerType,customProperites{:});%,'filled');
    end

    
    colormap(MarkerFaceColor); % this two line is not necessary.

%     sct.Children.MarkerFaceAlpha = 1;

%     ax2.Visible = 'off';
%     ax2.XTick = [];
%     ax2.YTick = [];
%     colormap(ax2,clr);
%     if nargout>1
%         varargout{1} = ax2; %
%     end
end


%% Summary
% info_t0 = datestr(dt0,'yyyymmdd');  
% info_t1 = datestr(dt1,'yyyymmdd');
% info_r = num2str([Rc0,Rc1]);
% info_M = num2str(MagRange(1:2));
% RcInfo = sprintf('EQ in %d <Rc<%d km',Rc0,Rc1);
% fprintf('M = [%s]; %s<catalog<%s ; Rc=[%s] km \n',info_M,info_t0,info_t1,info_r);

end

function [d1km d2km]=lldistkm(latlon1,latlon2)
% format: [d1km d2km]=lldistkm(latlon1,latlon2)
% Distance:
% d1km: distance in km based on Haversine formula
% (Haversine: http://en.wikipedia.org/wiki/Haversine_formula)
% d2km: distance in km based on Pythagoras?theorem
% (see: http://en.wikipedia.org/wiki/Pythagorean_theorem)
% After:
% http://www.movable-type.co.uk/scripts/latlong.html
%
% --Inputs:
%   latlon1: latlon of origin point [lat lon]
%   latlon2: latlon of destination point [lat lon]
%
% --Outputs:
%   d1km: distance calculated by Haversine formula
%   d2km: distance calculated based on Pythagoran theorem
%
% --Example 1, short distance:
%   latlon1=[-43 172];
%   latlon2=[-44  171];
%   [d1km d2km]=distance(latlon1,latlon2)
%   d1km =
%           137.365669065197 (km)
%   d2km =
%           137.368179013869 (km)
%   %d1km approximately equal to d2km
%
% --Example 2, longer distance:
%   latlon1=[-43 172];
%   latlon2=[20  -108];
%   [d1km d2km]=distance(latlon1,latlon2)
%   d1km =
%           10734.8931427602 (km)
%   d2km =
%           31303.4535270825 (km)
%   d1km is significantly different from d2km (d2km is not able to work
%   for longer distances).
%
% First version: 15 Jan 2012
% Updated: 17 June 2012
%--------------------------------------------------------------------------

radius=6371; % radius of earth
lat1=latlon1(1)*pi/180;
lat2=latlon2(1)*pi/180;
lon1=latlon1(2)*pi/180;
lon2=latlon2(2)*pi/180;
deltaLat=lat2-lat1;
deltaLon=lon2-lon1;
a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLon/2)^2;
c=2*atan2(sqrt(a),sqrt(1-a));
d1km=radius*c;    %Haversine distance

x=deltaLon*cos((lat1+lat2)/2);
y=deltaLat;
d2km=radius*sqrt(x*x + y*y); %Pythagoran distance

end