% INPUT: 
%     Required: 
%         X (original data, n*1 array each)
%         Y (original data, n*1 array each)
%     Optional:
%         DF1.fitt, DF2.fitt... to DFn.fitt:
%         only accept fitt as the output of 'fit''
%             e.g. DF1=DataFit(~); ...;  DataFitPlot(X,Y,{DF1, DF2})
%     Parameters:


%          text_: x_pos = text_{1}; y_pos = text_{2}; text_str = text_{3};   text(x_pos,y_pos,text_str);
%          e.g. 'text_',{[2 8],[7 7],{'text1','text2'}} will add text at x=2,y=7, string = 'text1'
function [] = DataFitPlot(X,Y,varargin)
default_legend = {'data'};
   p = inputParser;
   %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
%    addRequired(p,'X');
%    addRequired(p,'Y');
   addOptional(p,'DF',{});
   addParameter(p,'XScale','linear');      
   addParameter(p,'YScale','linear');      
   addParameter(p,'marker','bo');  
   addParameter(p,'Legend',default_legend);
   % legend(legend) will cause an error. Avoid use 'legend' as the name of variable
   addParameter(p,'Title','Data fitting results');
   addParameter(p,'PlotType',0);
   addParameter(p,'XLabel','X');
   addParameter(p,'YLabel','Y');
   addParameter(p,'LineStyle',{'r-', 'g--', '-.',':'});
%    addParameter(p,'text_',0);
   parse(p,varargin{:});
   rslt = p.Results;
%    X = rslt.X; Y = rslt.Y; 
   DF = rslt.DF;
   yscale_ = rslt.YScale; 
   xscale_ = rslt.XScale;
   marker = rslt.marker; legend_ = rslt.Legend; 
   title_ = rslt.Title;
   xlabel_ = rslt.XLabel; 
   ylabel_ = rslt.YLabel;  
   pltType = rslt.PlotType;  lineStyles = rslt.LineStyle;
   legend_auto = cell(1,numel(DF)+1);
   legend_auto{1}=default_legend{1};
    
% f1 = figure;
switch pltType
    case 0
        plot(X,Y,marker); %plot data
    case 'bar'
        bar(X,Y,1,'FaceAlpha',.5);% (X,Y,BarWidth)
end


if numel(DF) > 0
    hold on
    for i=1:numel(DF)
        LineStyle_i = lineStyles{ rem(i-1,numel(lineStyles))+1 };
%         assignin('base','LSi',LineStyle_i);% for debug
        plt = plot(DF{i}.fitt, LineStyle_i); %plot fitted curve
%         set(plt,'LineStyle',LineStyle_i);
        legend_auto{i+1} = DF{i}.fit_to;
        set(plt,'LineWidth',2); % plot(fitt,'LineWidth',1); raise error
    end
    hold off
end


if  isequal(legend_,default_legend) == 1
    legend_ = legend_auto;
end

legend(legend_,'Location','best');
title(title_);
xlabel(xlabel_);
ylabel(ylabel_);
set(gca,'YScale',yscale_,'XScale',xscale_);

% ax_lim = {xlim,ylim}; % 1 for x, 2 for y.
% if ~isempty(text_)
%     if ischar(text_{1})
%         for pos_i = 1:2 % 1 for x, 2 for y.
%             switch text_{pos_i}
%                 case {'left', 'bottom'}
%                     text_{pos_i} = ax_lim{pos_i};
%                 case {'right', 'top'}
%                     ...
%                 case 'center'
%                     ...
%             end
%         end
% 
%     else
%         x_pos = text_{1}; y_pos = text_{2}; text_str = text_{3}; 
%     end
%     text(x_pos,y_pos,text_str);
% end

%% annotation
% other_info = {'best fitting parameter:'};
%     for i = 1:numel(DF)
%         info_i = sprintf('%s: %.2f',DF{i}.fit_to,DF{i}.best_fit_coeff);
%         other_info = [other_info; info_i];
%     end
% config1.VerticalAlignment = 'bottom';
% annote(other_info,[0.13 0.1 0.5 0.3],f1,config1);

end

function annote(text,pos,fig,config)
dim = pos;  
a=annotation(fig,'textbox',dim,'String','');
%建立annotation時必定要先設定contanier(可以是方形、橢圓、箭頭)的大小和他的對應文字
a.String = text;
a.LineStyle='none';%設定沒有外框

    if isfield(config,'HorizontalAlignment') % 'left' (default) | 'center' | 'right'
        %Alignment 是指 文字對齊於textbox的'左'、'中'或'右'側
       a.HorizontalAlignment = config.HorizontalAlignment;
    end
    
    if isfield(config,'VerticalAlignment') % 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
       a.VerticalAlignment = config.VerticalAlignment;
    end
    
    if isfield(config,'FontSize')
       a.FontSize = config.FontSize;
    end

end

