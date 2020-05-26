function [f, xi] = safeksdensity(input_timeseries,varargin)
% this produce safer pdf, but it could be much slower.
% this is incompleted and might not be completed forever.
maxiter = 15;
otheroptions = {};
if nargin>1
    pts = varargin{1}; 
    otheroptions = [{pts}, otheroptions];
end


good = false;
for i = 1:maxiter
    [f, xi] = ksdensity(input_timeseries,otheroptions{:});
    dx = gradient(x);
    dfdx = gradient(pdfx)./dx; %gradient(pdfx,dx(1)); 
    if dx > dfdx
        
    end
        
    if good
        break
    end
end
if i == maxier
    warning('[safeksdensity] Maximum iteration reached; output pdf might not be good enough.');
end

end

