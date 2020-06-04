function [catalog_F] = eventFilter(catalog,varargin)
% catalog_F = EQinRange(catalog)
% input: 
%     catalog 
%         catalog should be a table with fields (VariableNames) 'Lon', 'Lat', 'Mag', 'Depth', 'Datetime'.
%         Use loadSheet.m to load catalog: catalog = loadSheet(filepath,'CWBcatalog');
% Name-value parameter:
%         ...,'Radius',0); % {[Lat,Lon],[r0,r1]} or  {[Lat,Lon],[r1]} % r0=0 by default
%         ...,'ConsiderDepth',0); % Filtering the catalog with 'Radius' 
%                 without considering depth of the earthquake. (default is 1, which is much slower)
%         ...,'Magnitude',0); % [LowerBound, UpperBound] of event magnitude.
%         ...,'TimeRange',0); % [LowerBound, UpperBound] of event magnitude.
% output:
%     catalog_F = only events in the specified 'TimeRange', 'Magnitude', 'Radius' around point P... and etc. radius Rc .

errorStruct.identifier = 'Custom:Error';
valid10 = @(x) (x==1) || (x==0);
% validcell = @(x) iscell(x) && length(x) == 2;
% PlotEpicenter has to be 1 (plot on map), cell (custom options in plot) 
% or string ('map' or 'regular' using default options)

p = inputParser;
% addRequired(p,'catalog');
addParameter(p,'Radius',0); % {[Lat,Lon],[r0,r1]} or  {[Lat,Lon],[r1]} % r0=0 by default
addParameter(p,'Magnitude',0); % [LowerBound, UpperBound] of event magnitude.
addParameter(p,'TimeRange',0); % [LowerBound, UpperBound] of event magnitude.
% addParameter(p,'PlotVerticalLine',0); USE vLinePlot_EventTime() instead
% addParameter(p,'PlotEpicenter',0,validPlotEpicenter); % USE plotEpicenter() instead.
addParameter(p,'ConsiderDepth',1,valid10);

parse(p,varargin{:});
rslt = p.Results;
conDep = rslt.ConsiderDepth;
Radius = rslt.Radius;
MagRange = rslt.Magnitude;
TimeRange = rslt.TimeRange;


%% select by time
if isequal(TimeRange,0)
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