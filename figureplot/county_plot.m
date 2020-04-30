function county_plot(varargin)
p = inputParser;
addParameter(p,'LineWidth',1.5);
addParameter(p,'EdgeAlpha',1);
parse(p,varargin{:});
LWidth = p.Results.LineWidth;
EdgeAlpha = p.Results.EdgeAlpha;

patchOptions = {'facecolor','none','edgecolor',[0 0 0],'lineWidth',LWidth,...
    'EdgeAlpha',EdgeAlpha};
county=shaperead('county.shp');
%inn= false(600,601);
for i=[1:9 11:22]  % 10¬O¼ê´ò¿¤
    in=find(isnan(county(i).X)==1);
    co=[county(i).X' county(i).Y'];   
    for j=1:length(in)
        hold on
        if j==1
            h=patch(co(1:in(j)-1,1),co(1:in(j)-1,2),ones(length(co(1:in(j)-1,2)),1).*0,[0 0 0],...
                patchOptions{:});
%             alpha(h,0)
%          in=inpolygon(rmx,rmy,co(:,1),co(:,2));
%          inn=inn+in;
        else
            h=patch(co(in(j-1)+1:in(j)-1,1),co(in(j-1)+1:in(j)-1,2),ones(length(co(in(j-1)+1:in(j)-1,2)),1).*0,[0 0 0],...
                patchOptions{:}); 
%             alpha(h,0)
%         in=inpolygon(rmx,rmy,co(in(j-1)+1:in(j)-1,1),co(in(j-1)+1:in(j)-1,2));
        end
    end 
end

end