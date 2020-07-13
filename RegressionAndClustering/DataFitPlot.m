% INPUT: 
function [legend_auto] = DataFitPlot(DF,varargin)
default_legend = {'data'};
NDF = numel(DF);
[linestyles] = specsGenerator('LineStyle',NDF);
p = inputParser;
% legend(legend) will cause an error. Avoid use 'legend' as the name of variable
addParameter(p,'LineStyle',linestyles);

parse(p,varargin{:});
rslt = p.Results; 
linestyles = rslt.LineStyle;
legend_auto = cell(1,numel(DF)+1);
legend_auto{1}=default_legend{1};

if ~iscell(DF)
    DF = {DF};
end



hold on
for i=1:numel(DF)
    LineStyle_i = linestyles{i};
    plt = plot(DF{i}.fitt, LineStyle_i); %plot fitted curve
    legend_auto{i+1} = DF{i}.fit_to;
    set(plt,'LineWidth',2); % plot(fitt,'LineWidth',1); raise error
end
end