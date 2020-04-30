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


