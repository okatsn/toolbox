function [array1] = anotherRange(startstop,length,varargin)
% [array1] = anotherRange([0,1],100)
% [array1] = anotherRange([0,1],100,@logspace)
functionHandle = @linspace;
if nargin > 2
    firstarg = varargin{1};
    if strcmp(firstarg,'log')
        functionHandle = @logspace;
        startstop = log10(startstop);
    end
end

array1 = functionHandle(startstop(1),startstop(2),length);

end

