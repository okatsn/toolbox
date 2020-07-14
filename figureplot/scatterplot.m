function plot_handles = scatterplot(X,Y,varargin)
% scatterplot use plot iteratively to plot each point.
% scatterplot can do highly custom tasks (like X,Y being points of different
% marker) that scatter cannot achieve; however, sctterplot is definitely
% slower than scatter.
% Examples:
%     scatterplot(X,Y,'Color',{[1,0,0],'r','g','b',[0.5,0.1,0.2]},...
%                  'Marker',{'*','^','p','h','o'},...
%                  'LineWidth',2.5);
%
%     ax = axes(); % or ax = gca;
%     scatterplot(ax,X,Y,...);

if ishghandle(X)
    ax = X;
    X = Y;
    Y = varargin{1};
    varargin(1) = [];
    if ischar(Y) || isStringScalar(Y)
        error("Incorrect input syntax. 'scatterplot(ax,X,Y,...)' is expected.");
    end
else
    ax = gca;
end
hold(ax,'on');
if size(X)~=size(Y)
    error("The size of X and Y are inconsistent.");
end


numplot = numel(X);
p = inputParser;
addParameter(p,'Marker',0);
addParameter(p,'Color',0);
addParameter(p,'LineWidth',0);
parse(p,varargin{:});
mrks = p.Results.Marker;
clrs = p.Results.Color;
lwidth = p.Results.LineWidth;

plot_options = cell(numplot,0);
if ~isequal(clrs,0)
    Noclr = numel(clrs);
    if Noclr~=numplot
        if iscell(clrs)
            error('Length inconsistent. Specs should be the same number of elements as the length of X, Y');
        elseif isnumeric(clrs) && rem(Noclr,3) == 0
            if size(clrs,1) == 1
                clrs = repmat(clrs,numplot,1);
                clrs = mat2cell(clrs,ones(1,numplot));
            else % size(clrs,1) > 1
                clrs = mat2cell(clrs,ones(1,numplot));
            end
        elseif ischar(clrs) || isStringScalar(clrs)
            clrname = clrs;
            clrs = cell(numplot,1);
            clrs(:) = {clrname};
        else
            error("Other error when specifying 'Color'");
        end
    end
    specs = cell(numplot,2);
    specs(:,1) = {'Color'};
    specs(:,2) = clrs;
    plot_options = [plot_options,specs];
end

if ~isequal(mrks,0)
    Nomrks = numel(mrks);
    if Nomrks~=numplot
        if iscell(mrks)
            error('Length inconsistent. Specs should be the same number of elements as the length of X, Y');
        elseif isnumeric(mrks)
            error("'Marker' shouldn't be numeric");
        elseif ischar(mrks) || isStringScalar(mrks)
            mrkname = mrks;
            mrks = cell(numplot,1);
            mrks(:) = {mrkname};
        else
            error("Other error when specifying 'Marker'");
        end
    end
    specs = cell(numplot,2);
    specs(:,1) = {'Marker'};
    specs(:,2) = mrks;
    plot_options = [plot_options,specs];
end

if ~isequal(lwidth,0)
    Nwidth = numel(lwidth);
    if Nwidth~=numplot
        if iscell(lwidth)
            error('Length inconsistent. Specs should be the same number of elements as the length of X, Y');
        elseif isnumeric(lwidth) && Nwidth == 1
            lwidth = repmat(lwidth,numplot,1);
            lwidth = mat2cell(lwidth,ones(1,numplot));
        else
            error("Other error when specifying 'LineWidth'");
        end
    end
    specs = cell(numplot,2);
    specs(:,1) = {'LineWidth'};
    specs(:,2) = lwidth;
    plot_options = [plot_options,specs];
end


plot_handles = gobjects(1,numplot);

for i = 1:numplot
    plot_handles(i) = plot(ax,X(i),Y(i),plot_options{i,:},'LineStyle','none');
end
hold(ax,'off');
end

