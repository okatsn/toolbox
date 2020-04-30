function [] = lazy_text(xticks_,yticks_,text_,varargin)
% locations = {'North','South','East', 'West','NorthEast','SouthEast','NorthWest','SouthWest'}
   p = inputParser;
   %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
   addRequired(p,'xticks');
   addRequired(p,'yticks');
   addRequired(p,'text');
%    addOptional(p,'DF',{});
   addParameter(p,'Position','Center');     
   parse(p,xticks_,yticks_,text_,varargin{:});
   rslt = p.Results;
   xticks_ = rslt.xticks; 
   yticks_ = rslt.yticks; 
   text_ = rslt.text;
   Pos = rslt.Position; 
   
Ans = regexp(Pos,'[A-Z][a-z]*','match');
alignment = 'center';

xTks = numel(xticks_)-1;
yTks = numel(yticks_)-1;
assignin('base','Ans',Ans);
partition = 5;

for i= 1:numel(Ans)
    switch Ans{i}
        case {'South','S'}
            idx = ceil(yTks/partition);
            c_y = yticks_(idx); % + margin*hght; 
        case {'North','N'}
            idx = yTks - ceil(yTks/partition);
            c_y = yticks_(idx); % - margin*hght;
        case {'West','W'}
            idx = ceil(xTks/partition);
            c_x = xticks_(idx); %+ margin*wdth; 
        case {'East', 'E'}
            idx = xTks - ceil(xTks/partition);
            c_x = xticks_(idx);% - margin*wdth;  
%             alignment = 'right';
        case 'Center'
            c_x = xticks_(round(xTks/2)); 
            c_y = yticks_(round(yTks/2));          
    end
end
% assignin('base','c_x',c_x);
% assignin('base','c_y',c_y);
% assignin('base','xticks_',xticks_);
% assignin('base','yticks_',yticks_);
% assignin('base','hght',hght);
text(c_x,c_y,text_,'HorizontalAlignment',alignment);
end

