function T = lazytext(info, varargin)
% Lazy text by Zeng-Kai
% default value for inputParser


default_property = {'Units', 'normalized'...
                    'VerticalAlignment', 'middle',...
                    'HorizontalAlignment', 'center'};
locations = {'North', 'South', 'East', 'West',...
             'NorthEast', 'SouthEast', 'NorthWest', 'SouthWest', 'Center'};
locationAbbrevs = cell(1,length(locations));
for k=1:length(locations)
    str = locations{k};
    locationAbbrevs{k} = str(str>='A' & str<='Z'); % logical mask of A~Z(uppercase)
end
locations = [locations, locationAbbrevs];

% position shifting
S = 0.35; % shift value
pos_shift = {[0, S, 0], [0, -S, 0], [S, 0, 0], [-S, 0, 0],...
    [S, S, 0], [S, -S, 0], [-S, S, 0], [-S, -S, 0], [0, 0, 0]};
pos_shift = repmat(pos_shift, 1, 2); % for abbreviations

% parser
p = inputParser;
addRequired(p, 'info')
addParameter(p, 'Location', 'NorthEast',...
    @(x) any(validatestring(x, locations)));
addParameter(p, 'axis', 0);
addParameter(p, 'Position', 0);
addParameter(p, 'property', default_property);
parse(p, info, varargin{:});

% assign parser Results
info = p.Results.info;
Loc = p.Results.Location;
ax = p.Results.axis;
text_property = [default_property, p.Results.property];
Pos = p.Results.Position;

% Write text on a specific axis object if the user passes the axis
if isobject(ax)
    T = text(ax, 0.5, 0.5, info, text_property{:});
else
    T = text(0.5, 0.5, info, text_property{:});
end

if isequal(Pos,0)
    locationCmp = strcmp(Loc, locations); % or use strcmpi(Loc, locations)
    T.Position = T.Position + pos_shift{locationCmp};
else
    T.Units = 'normalized';
    T.Position = [Pos,0];
end

% function [] = lazytext(gcf_,text_,varargin)
% % 利用legend自動找最適當的text位置
% % locations = {'North','South','East', 'West','NorthEast','SouthEast','NorthWest','SouthWest'}
%    p = inputParser;
%    %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
%    addRequired(p,'gcf');
%    addRequired(p,'text');
% %    addOptional(p,'DF',{});
%    addParameter(p,'Location','best');     
% %    addParameter(p,'VerticalAlignment','best');
%    parse(p,gcf_,text_,varargin{:});
%    rslt = p.Results; 
%    gcf_ = rslt.gcf; 
%    text_ = rslt.text;
%    Loc = rslt.Location; 
%    
%    h_align = 'center';
%    v_align = 'bottom';
%    flag = 0;
%    
%    try
%    lgd = gcf_.Children.findobj('-regexp', 'Tag', 'legend');
%    catch
%        lgd = legend('Location',Loc);
%        flag = 1;
%    end
%    
%    lgdLoc = lgd(1).Location;
%    lgd(1).Location = Loc;
%    lgdPos = lgd(1).Position;
%    % lgd(1) is always the legend of last subplot. % lgd(end) is always the first subplot
%      
%    z =0;
%     T = text(0,0,text_); % text位置先隨便放，之後再改
%     T.Units = 'normalized'; % 原本T.Units 是 'data' % 詳見 T.Children
%     T.Position = [lgdPos(1:2), z]; % text position is the coordinate of x,y,z axis.
%     T.HorizontalAlignment =  h_align;% 'left' 'center' 'right'
%     T.VerticalAlignment = v_align;% 'top', 'middle' ,'bottom'
%     
%    if flag
%         % delete legend
%     else
%         lgd(1).Location = lgdLoc; % 復原legend為原本的設定
%     end
%     
% 
%     
% end 



