function [outputArg1,outputArg2] = adjText(varargin)

Settings = {};
NameDefaultvaluePair_cell = {'Shift',[0,0],'Larger',12};
[r,varargin] = inputParser2(varargin,Settings,NameDefaultvaluePair_cell);

LoV = length(varargin);

inc = 0.01;

for i = 1:LoV
    tt= varargin{i};
    FontSz = tt.FontSize;
    tt.Units = 'normalized';
    
    if r.Larger
        if isnumeric(r.Larger)
            FontSz = r.Larger;
        else
            FontSz = 12;%default larger text font size
        end
    end

    tt.FontSize = FontSz;
    
    tt.Position = tt.Position + [r.Shift,0];
end


end

