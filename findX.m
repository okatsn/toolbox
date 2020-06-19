function k = findX(mtf,fieldName,varargin)
% find non-zero element of large array from matfile.
error("This function is incomplete.");


do_nothing = @(x) x;
sizeX = size(mtf,fieldName);

p = inputParser;
addParameter(p,'FunctionHandle',do_nothing);
addParameter(p,'First',0);

parse(p,varargin{:});
n = p.Results.First;
fcnHandle = p.Results.FunctionHandle;

nloops = ceil(lenX/limitnumel);
length_seg 

for i = 1:nloops
    x = mtf.(fieldName)()
end

end

