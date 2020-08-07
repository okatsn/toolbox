
classdef viscous
methods (Static)
    function FitFunction = TrErF_ccdf() % case 'TruncatedErF_CCDF' % double check required
        % truncated error function
%         FitFunction = @(b,t)          1-erf(0.5*sqrt(2)*sqrt(1/b(1))*t)/erf(0.5*sqrt(2)*sqrt(1/b(1))*b(2)); 
        disp('model TrErF_ccdf: b(1) is u_avg; b(2) is u_max. See Mai2016.');
      FitFunction = @(uavg,umax,t)  1-erf(0.5*sqrt(2)*sqrt(1/uavg)*t)/erf(0.5*sqrt(2)*sqrt(1/uavg)*umax); 
    end
end
end