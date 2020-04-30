function [] = mapplot(varargin)
% plot 2D map, or overlap the map on a 3D graph with normal in Z direction
% e.g. mapplot('Function','plot3','Z',mapZ,'Options',{'LineWidth',1.5});%,'LatLim',TwLatLim,'LonLim',TwLonLim);
% e.g. mapplot('Options',{'LineWidth',0.5},'LatLim',[21 23],'LonLim',[121 122]););

TwLatLim=[21.5 26];
TwLonLim=[118 122.5];
p = inputParser;
addParameter(p,'ShapefilePath','county.shp');% presumed to be in the toolbox.
addParameter(p,'LatLim',TwLatLim); % Region of taiwan
addParameter(p,'LonLim',TwLonLim); % Region of taiwan
addParameter(p,'Function','patch');
addParameter(p,'Options',{});
addParameter(p,'Z',0);
parse(p,varargin{:});
LatLim = p.Results.LatLim; LonLim = p.Results.LonLim; 
shpfile = p.Results.ShapefilePath;
options = p.Results.Options;
Func = p.Results.Function;
Z = p.Results.Z;
if Z==0
   warning('mapplot.m plot the shape at Z = 0.'); 
end


if ~isequal(LatLim,TwLatLim)||~isequal(LonLim,TwLonLim)
    doXYLim = true;
else
    doXYLim = false;
end
try
    county=shaperead(shpfile);
catch ME
    switch ME.identifier
        case 'map:shapefile:failedToOpenSHP'
            error("Failed in loading '%s'. File may not exist in current directory or toolbox.",shpfile);
        otherwise
            rethrow(ME);
    end
end
% %inn= false(600,601);
% for i=[1:9 11:22]  % 10¬O¼ê´ò¿¤
%     in=find(isnan(county(i).X)==1);
%     co=[county(i).X' county(i).Y'];   
%     for j=1:length(in)
%         hold on
%         if j==1
%             h=patch(co(1:in(j)-1,1),co(1:in(j)-1,2),ones(length(co(1:in(j)-1,2)),1).*0,[0 0 0],'facecolor','none','edgecolor',[0 0 0],'lineWidth',1.5);
% %             alpha(h,0)
% %          in=inpolygon(rmx,rmy,co(:,1),co(:,2));
% %          inn=inn+in;
%         else
%             h=patch(co(in(j-1)+1:in(j)-1,1),co(in(j-1)+1:in(j)-1,2),ones(length(co(in(j-1)+1:in(j)-1,2)),1).*0,[0 0 0],'facecolor','none','edgecolor',[0 0 0],'lineWidth',1.5); 
% %             alpha(h,0)
% %         in=inpolygon(rmx,rmy,co(in(j-1)+1:in(j)-1,1),co(in(j-1)+1:in(j)-1,2));
%         end
%     end 
% end
for i = 1:22
    switch Func
        case 'patch'
            patch(county(i).X,county(i).Y,0.5*ones(size(county(i).Y)),options{:});
            % no significant difference between plot or patch...
        case 'plot'
            plot(county(i).X,county(i).Y,'Color','k',options{:});
        case 'plot3'
            plot3(county(i).X,county(i).Y,Z*ones(size(county(i).Y)),'Color','k',options{:});
    end
           
    hold on
end
% axis equal
if doXYLim
    xlim(LonLim); ylim(LatLim);
end
end

