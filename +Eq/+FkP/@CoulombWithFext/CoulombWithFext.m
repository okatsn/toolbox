classdef CoulombWithFext
% function handle manager:
% this function stores the derived functions in one place, to avoid typo or
% other artificial error.

methods (Static)
    function P0 = P0()
        % coefficient for normalization
        P0 = @(r,Fc,D) (Fc^2- r^2)/(-2*r*D); 
        % see '(2020) Solve SDE for DRY friction.mw'
    end
    
    function [FitFunction] = Pst()
        % see Wu2020 (not submit yet)
        FitFunction = @(P0,r,Fc,D,v) P0*exp(Fc*v/D).*exp(-r*v.*sign(v)/D);
    end
    
    
%     function [FitFunction] = Pst2()
%         % This way failed.
%         P0 = Eq.FkP.CoulombWithFext.P0;
%         FitFunction = @(v,r,Fc,D) P0(r,Fc,D)*exp(Fc*v/D).*exp(-r*v.*sign(v)/D);
%     end
    
    function [f_neg,f_pos] = Pst_cases() % another equivalent form of Pst_CoulombFext_Wu2020
        f_neg = @(P0,r,Fc,D,v) P0*exp((Fc + r)*v/D); % for v <= 0
        f_pos = @(P0,r,Fc,D,v) P0*exp((Fc - r)*v/D); % for v > 0
    end
    
    function [TEX_neg,TEX_pos] = trPst_cases()
        fn = @(P0,r,Fc,D,v) P0*exp((Fc + r)*v/D); % f_neg, for v <= 0
        fp = @(P0,r,Fc,D,v) P0*exp((Fc - r)*v/D); % f_pos, for v > 0
        int_fn = @(P0,r,Fc,D,v) P0*D/(Fc+r)*exp((Fc + r)*v/D); % integral form
        int_fp = @(P0,r,Fc,D,v) P0*D/(Fc-r)*exp((Fc - r)*v/D);
        Pin = @(vmin,vmax,P0,r,Fc,D) (int_fn(P0,r,Fc,D,0) - int_fn(P0,r,Fc,D,vmin)) + (int_fp(P0,r,Fc,D,vmax)- int_fp(P0,r,Fc,D,0));
        TEX_neg = @(vmin,vmax,P0,r,Fc,D,v) fn(P0,r,Fc,D,v)/Pin(vmin,vmax,P0,r,Fc,D);
        TEX_pos = @(vmin,vmax,P0,r,Fc,D,v) fp(P0,r,Fc,D,v)/Pin(vmin,vmax,P0,r,Fc,D);
%         f_pos = @(v,P0,r,Fc,D) P0*exp((Fc - r)*v/D)/(((P0*D/(Fc+r)-P0*D/(Fc+r)*exp((Fc + r)*vmin/D))-()); % for v > 0
    end
%     P0*D/(Fc-r)*exp((Fc - r)*v/D)-P0*D/(Fc-r)


%     case 'GRlaw'
%     function FitFunction = GRlaw()
%         FitFunction = @(a,b,t) 10.^(a-b*(2/3)*log10(t)-6.07);
%     end



end
end

