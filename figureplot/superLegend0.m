function [supertitleHandle] = superLegend(supertitle_string,varargin)
NameOnly_cell = {'legend'};

TextOption = {'FontSize',14,'FontWeight','Bold','HorizontalAlignment','Center','VerticalAlignment','Bottom'};
TextPosition = {0,0};
AxesPosition = [0,0.95,1,0.05];

[Results2,varargin2] = inputParser2(varargin,NameOnly_cell);

p = inputParser;
% p.KeepUnmatched = true;
p = inputParser;
addParameter(p,'AxesPosition',AxesPosition);
addParameter(p,'TextPosition',TextPosition);
addParameter(p,'TextProperties',TextOption);
addParameter(p,'Markers',0);
parse(p,varargin2{:});





TextOption = p.Results.Properties;
TextPosition = p.Results.TextPosition;
AxesPosition = p.Results.AxesPosition;

supertitleHandle = axes('Position',AxesPosition);
supertitleHandle.Color = 'none';
supertitleHandle.XColor = 'none';
supertitleHandle.YColor = 'none';
text(TextPosition{:},supertitle_string,TextOption{:});
end

