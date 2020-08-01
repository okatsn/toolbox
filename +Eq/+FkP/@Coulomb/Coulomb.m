
classdef Coulomb
methods (Static)
    function FitFunction = TEX_ccdf() % case {'TEX_CCDF','TEX(CCDF)'}
        % see Mai2016
            FitFunction = @(t,uavg,umax)  (exp(-t/uavg)-exp(-umax/uavg))/(1-exp(-umax/uavg) ); 
    end
    
    function FitFunction = EXP() % case 'EXP'
        % see Mai2016
        FitFunction = @(t,uavg)  (1/uavg)*(exp(-t/uavg));
    end

    function FitFunction = EXP_ccdf() % case 'EXP_CCDF'
        % see Mai2016
        FitFunction = @(t,uavg)  (exp(-t/uavg));
    end    
end


end