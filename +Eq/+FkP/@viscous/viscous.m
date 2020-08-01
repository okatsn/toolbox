
classdef viscous
methods (Static)
    function FitFunction = TrErF_ccdf() % case 'TruncatedErF_CCDF' % double check required
        % truncated error function
        FitFunction = @(t,uavg,umax)  1-erf(0.5*sqrt(2)*sqrt(1/uavg)*t)/erf(0.5*sqrt(2)*sqrt(1/uavg)*umax); 
    end
end
end