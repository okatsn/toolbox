function [sct] = plotEpicenter(catalog_F,varargin)
% e.g.
%     catalog = loadSheet(filepath,'CWBcatalog');
%     [catalog2] = eventFilter(catalog,varargin);
%     figure;
%     plotEpicenter(catalog2);
% Plot epicenter with marker filled:
%     plotEpicenter(catalog_outside,'filled');
% Plot epicenter on a map object:
%     plotEpicenter(catalog_outside,'map');


 

%% Plot epicenter
hot1 = flipud(hot);
hot1(1:20,:) = []; % remove those too bright in the color bar.
NameOnly_cell = {'filled','map'};
validPlotEpicenter = @(x) isequal(x,1)||isequal(x,0)||isa(x,'cell')||any(validatestring(x,NameOnly_cell));
validMarkerSize = @(x) isa(x,'double') && length(x) < 3;

[Results2,function_varargin2] = inputParser2(varargin,NameOnly_cell);

p = inputParser;
p.KeepUnmatched = true;
addParameter(p,'MarkerSize',5,validMarkerSize); % [a,b]; where marker size will be a + b*Magnitude.
% addParameter(p,'ScatterProperties',{});
addParameter(p,'colormap',hot1);
% addParameter(p,'MarkerFaceColor');
% addParameter(p2,'MarkerEdgeColor','none');

parse(p,function_varargin2{:});
MarkerSize0 = p.Results.MarkerSize;
clrmap = p.Results.colormap;
customProperites = namedargs2cell(p.Unmatched);% p.Results.ScatterProperties;
   
    
MarkerSizes = [5,25]; % default value

if length(MarkerSize0)==1
    MarkerSizes(1) = MarkerSize0; 
    MarkerSizes(2) = 0; % constant marker size
%                     MarkerSizes(:) = MarkerSize0;
elseif length(MarkerSize0)==2
    MarkerSizes = MarkerSize0;
else 
    warning("[plotEpicenter] 'MarkerSize' ignored because the dimension is not legal.")
end

mkrsize = MarkerSizes(1) + (catalog_F.Mag)*MarkerSizes(2)*5;

if Results2.filled
    customProperites = [{'filled'},namedargs2cell(p.Unmatched)];
end
    
if size(clrmap,1)==1 || ischar(clrmap) || isStringScalar(clrmap) % only one color
    mkcolor = clrmap;
else
    colormap(clrmap);
    mkcolor = catalog_F.Mag;
end

markerType = 'p';% 5-cornered star.

if Results2.map
    sct = scatterm(catalog_F.Lat,catalog_F.Lon,mkrsize,mkcolor,markerType,customProperites{:});%,'filled');
    % sct_m has no field 'Marker'
else
    sct = scatter(catalog_F.Lon,catalog_F.Lat,mkrsize,mkcolor,customProperites{:});%,'filled');
    sct.Marker =markerType; % 

end
    

end

