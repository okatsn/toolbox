function [] = lazytext(gcf_,text_,varargin)
% 利用legend自動找最適當的text位置
% locations = {'North','South','East', 'West','NorthEast','SouthEast','NorthWest','SouthWest'}
   p = inputParser;
   %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
   addRequired(p,'gcf');
   addRequired(p,'text');
%    addOptional(p,'DF',{});
   addParameter(p,'Location','best');     
%    addParameter(p,'VerticalAlignment','best');
   parse(p,gcf_,text_,varargin{:});
   rslt = p.Results; 
   gcf_ = rslt.gcf; 
   text_ = rslt.text;
   Loc = rslt.Location; 
   
   h_align = 'center';
   v_align = 'bottom';
   flag = 0;
   
   try
   lgd = gcf_.Children.findobj('-regexp', 'Tag', 'legend');
   catch
       lgd = legend('Location',Loc);
       flag = 1;
   end
   
   lgdLoc = lgd(1).Location;
   lgd(1).Location = Loc;
   lgdPos = lgd(1).Position;
   % lgd(1) is always the legend of last subplot. % lgd(end) is always the first subplot
     
   z =0;
    T = text(0,0,text_); % text位置先隨便放，之後再改
    T.Units = 'normalized'; % 原本T.Units 是 'data' % 詳見 T.Children
    T.Position = [lgdPos(1:2), z]; % text position is the coordinate of x,y,z axis.
    T.HorizontalAlignment =  h_align;% 'left' 'center' 'right'
    T.VerticalAlignment = v_align;% 'top', 'middle' ,'bottom'
    
   if flag
        % delete legend
    else
        lgd(1).Location = lgdLoc; % 復原legend為原本的設定
    end
    

    
end 

