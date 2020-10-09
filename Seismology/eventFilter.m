function [catalog_F,target_ind] = eventFilter(catalog,varargin)
% catalog_F = eventFilter(catalog)
% input: 
%     catalog 
%         catalog should be a table with fields (VariableNames) 'Lon', 'Lat', 'Mag', 'Depth', 'Datetime'.
%         Use loadSheet.m to load catalog: catalog = loadSheet(filepath,'CWBcatalog');
% Name-value parameter:
%         ...,'Radius',0); 
%             Disabled. I.e., no selection according to the event positions.
%
%         ...,'Radius',{[Lat,Lon],[r0,r1]});
%             Select the events whose distances d between [Lat,Lon] and 
%             events' hypocenters/epicenters satisfying r0 < d < r1. r0, r1
%             should be in the unit kilometer.
%
%         ...,'Radius',{[Lat,Lon],[r1]}; 
%             Same as above but with r0=0 by default
%         
%         LatLons = [LatLon1;LatLon2;...];% LatLon1 = [21, 122] for example
%         ...,'Radius', {LatLons,r1});
%             Select all earthquakes inside multiple ranges of radius r1 
%             centered at several points (LatLons) non-repeatedly. 
%             LatLons is an N by 2 array, and LatLon1 is 1 by 2.
%         
%         Rcs = [r1;r2;...];
%         ...,'Radius', {LatLons,Rcs});
%             Select all earthquakes inside multiple ranges, r1 centered at
%             LatLon1, r2 at LatLon2,..., non-repeatedly. 
%             Rcs can be either N by 1 or N by 2 array.
%             That is, it can be [r1_1;r1_2,...] 
%             or [r0_1,r1_1;r0_2,r1_2;...] that has identical number of
%             rows as LatLons.
%
%         ...,'Radius', {LatLon1,Rcs});
%             Select all earthquakes inside multiple ranges, Rcs centered 
%             at the same point LatLon1 (1 by 2 array), non-repeatedly. 
%
%         ...,'ConsiderDepth',0); 
%             Filtering the catalog with 'Radius' 
%             without considering depth of the earthquake.
%             That is, use the epicenters to calculate the distance.
%
%         ...,'ConsiderDepth',1);
%             Use the hypocenters to calculate the distance.
%             (default is 1, which is much slower than 0)
%
%         ...,'Magnitude',0); % [LowerBound, UpperBound] of event magnitude.
%
%         ...,'TimeRange',0); % [LowerBound, UpperBound] of event datetime.
%             It has to be 1 by 2 array of datenumber or datetime, or
%             characters containing two separated eight digits such as 
%             '20111212-20131013'.
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

height_tb = height(catalog);

%% select by time
if isequal(TimeRange,0)
% do nothing
    tidx = true(height_tb,1);
else
    try
        switch class(TimeRange)
            case 'double'
                dt0 = datetime(TimeRange(:,1),'ConvertFrom','datenum');
                dt1 = datetime(TimeRange(:,2),'ConvertFrom','datenum');
            case {'char','string'}
                A = regexp(TimeRange,'\d{8}','match');
                if length(A)>2
                    error("'TimeRange' for character inputs does not support multiple pairs of date strings.");
                end
                dt0 = datetime(A{1},'InputFormat','yyyyMMdd');
                dt1 = datetime(A{2},'InputFormat','yyyyMMdd');
            case 'datetime'
                dt0 = TimeRange(:,1);
                dt1 = TimeRange(:,2);
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
%     catalog = catalog(tidx,:);

end
%% Select by Magnitude
if isequal(MagRange,0)
    midx = true(height_tb,1);
else
    MagRange = [MagRange, 13];% no events will larger than 13;
    midx = catalog.Mag>= MagRange(1) & catalog.Mag<MagRange(2);
%     catalog = catalog(midx,:);
end
tmidx = tidx & midx;
%% Select by Radius

if ~isequal(Radius,0)
    ridx = false(height_tb,1); % false means to discard
    Depth = catalog.Depth;
    LatLon2 = [catalog.Lat,catalog.Lon]; 
    % faster to copy a certain variable from table before entering for loop.
    if istable(Radius)
        tb = Radius;
        try
            try
                Radius = {[tb.LatLon],tb.Rc};
            catch
                Radius = {[tb.Lat,tb.Lon],tb.Rc};
            end
        catch ME
            msg0 = strcat("For input a table as 'Radius', ",...
             "the table must contains fields 'Lat' for latitude, ",...
             "'Lon' for longitude ",...
             "(or 'LatLon' for latitude and longitude),",...
             " and 'Rc' for radius/distance.",...
             " (Original error: %s)");
            msg1 = sprintf(msg0,ME.message);
            errorStructTb.message = msg1;
            errorStructTb.identifier = ME.identifier;
            errorStructTb.stack = ME.stack;
            error(errorStructTb);
        end
    end
    
    if iscell(Radius)
        latlon1 = Radius{1};      
        Radius2 = Radius{2};
        numSt1 = size(latlon1,1);
        numSt2 = size(Radius2,1);
        if numSt1>1 && numSt2==1
            % if size(Radius{1},1) ~= size(Radius{2},1),
            % then repeat the array to make their number of rows identical
            Radius2 = repmat(Radius2,numSt1,1);
        elseif numSt2>1 && numSt1==1
            latlon1 = repmat(latlon1,numSt2,1);
        end
        
        RcRange = [zeros(numSt1,1), Radius2]; % Radius{2} may be e.g. 15 or [5,15]
        Rc0 = RcRange(:,end-1);
        Rc1 = RcRange(:,end);

        NoD = height_tb; %numel(catalog.DateTime);
        StHypDist = NaN(NoD,1);  %just for showing information
        
        switch conDep
            case 0
                for i = 1:NoD
                    if tmidx(i) % calculate only if in the range of magnitude and date time.
                        % otherwise, skip, because check if eqk in Rc is
                        % the most time consuming process.
                        for k = 1:numSt1
                            if ridx(i)
                                continue % since once ridx(i) is set to be
                                % true, it's enough and needless to
                                % consider other ranges.
                            end
                            
                            [eqdist , ~]=lldistkm(latlon1(k,:),LatLon2(i,:));
                            % d1km: distance in km based on Haversine formula
                            if eqdist<Rc1(k) && eqdist>Rc0(k)
                                ridx(i) = true; % true for selected
                                StHypDist(i) = eqdist;
                            end
                        end
                    end
                end
            case 1
                if any(Rc1>1000)
                    warning('Beware that distance is NOT calculated in 3D space, i.e. If Rc or Depth is very large, results deviate.');
                    % to get the real distance between the two points on
                    % earth, you may refer to lla2ecef or sph2cart
                end
                for i = 1:NoD
                    if tmidx(i) % calculate only if in the range of magnitude and date time.
                        % otherwise, skip, because check if eqk in Rc is
                        % the most time consuming process.
                        for k = 1:numSt1
                            if ridx(i)
                                continue % since once ridx(i) is set to be
                                % true (selected), it's enough and needless 
                                % to consider other ranges.
                            end
                            
                            [eqdist] = simpleStationEQKdist3D(latlon1(k,:),LatLon2(i,:),Depth(i));
%                             arclendeg=distance('gc',LatLonSt,LatLonEQK);
%                             arclenkm=deg2km(arclendeg);
%                             eqdist=sqrt(arclenkm.^2+DepthEQK.^2);
                            if eqdist<Rc1(k) && eqdist>Rc0(k)
                                ridx(i) = true; % true for selected
                                StHypDist(i) = eqdist;
                            end
                        end
                    end
                end
        end
    else
        errorStruct.message = "Incorrect input parameter 'Radius'. It should be {[Lat,Lon],[r0,r1]}.";
        error(errorStruct)
    end
else
    ridx = true(height_tb,1); % All true means all selected
end
target_ind = tmidx & ridx;
catalog_F = catalog(target_ind,:);
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