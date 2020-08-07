
classdef Coulomb
methods (Static)
    function FitFunction = TEX_ccdf() % case {'TEX_CCDF','TEX(CCDF)'}
        % see Mai2016
%             FitFunction = @(b,t)  (exp(-t/b(1))-exp(-b(2)/b(1)))/(1-exp(-b(2)/b(1)) ); 
%             disp('model TEX_ccdf: b(1) is u_avg; b(2) is u_max. See Mai2016.');
            FitFunction = @(uavg,umax,t)  (exp(-t/uavg)-exp(-umax/uavg))/(1-exp(-umax/uavg) ); 
    end
    
    function FitFunction = EXP() % case 'EXP'
        % see Mai2016
%         FitFunction = @(b,t)  (1/b(1))*(exp(-t/b(1)));
%         disp('model EXP: b(1) is u_avg. See Mai2016.');
        FitFunction = @(uavg,t)  (1/uavg)*(exp(-t/uavg));
    end

    function FitFunction = EXP_ccdf() % case 'EXP_CCDF'
        % see Mai2016
%         FitFunction = @(b,t)  (exp(-t/b(1)));
%         disp('model EXP_ccdf: b(1) is u_avg. See Mai2016.');
        FitFunction = @(uavg,t)  (exp(-t/uavg));
        
    end    
end


end