function [] = set_text(T,varargin)
   p = inputParser;
   addRequired(p,'T');
   addParameter(p,'Position',[.5 .5 0]);  
   addParameter(p,'Units','normalized');  
   addParameter(p,'HorizontalAlignment','center');  
   addParameter(p,'VerticalAlignment','bottom');  
   parse(p,T,varargin{:});
   rslt = p.Results; 
   T = rslt.T; 
   Pos = rslt.Position;
   VerticalAlignment = rslt.VerticalAlignment;
   HorizontalAlignment = rslt.HorizontalAlignment;
   Units = rslt.Units;
   
   T.Units = Units;
   T.Position = Pos;
   T.HorizontalAlignment = HorizontalAlignment;
   T.VerticalAlignment = VerticalAlignment;

end

