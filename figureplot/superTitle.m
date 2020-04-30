function [supertitleHandle] = superTitle(supertitle_string,varargin)

TextOption = {'FontSize',14,'FontWeight','Bold','HorizontalAlignment','Center','VerticalAlignment','Bottom'};
TextPosition = {0,0};
AxesPosition = [0,0.95,1,0.05];
p = inputParser;
addParameter(p,'AxesPosition',AxesPosition);
addParameter(p,'TextPosition',TextPosition);
addParameter(p,'TextOption',TextOption);
parse(p,varargin{:});
TextOption = p.Results.TextOption;
TextPosition = p.Results.TextPosition;
AxesPosition = p.Results.AxesPosition;

supertitleHandle = axes('Position',AxesPosition);
supertitleHandle.Color = 'none';
supertitleHandle.XColor = 'none';
supertitleHandle.YColor = 'none';
text(TextPosition{:},supertitle_string,TextOption{:});
end

