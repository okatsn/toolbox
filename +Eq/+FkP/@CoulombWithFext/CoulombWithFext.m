classdef CoulombWithFext
% function handle manager:
% this function stores the derived functions in one place, to avoid typo or
% other artificial error.

methods (Static)
    function [v_avg,v_avg_neg,v_avg_pos] = v_expectation(varargin)
        v_avg = @(F_C,F_ext,D) -2*D*F_ext/(F_ext^2 - F_C^2);
        % <v> = \int_{-\infty}^{+\infty} v p(v) dv ; see draft and guide.md
        v_avg_neg = @(F_C,F_ext,D) -D*(F_C-F_ext)/((2*F_C)*(F_ext+F_C));
        % <v-> = \int_{0}^{+\infty} v p(v) dv 
        v_avg_pos = @(F_C,F_ext,D) -D*(F_C+F_ext)/((2*F_C)*(F_ext-F_C));
        % <v+> = \int_{-\infty}^{0} v p(v) dv 
        if nargin == 0
            return
        elseif nargin == 3
            v_avg = v_avg(varargin{:});
            v_avg_neg = v_avg_neg(varargin{:});
            v_avg_pos = v_avg_pos(varargin{:});
        else
            error('invalid number of input argument');
        end
    end
    function P0 = P0(varargin)
        % coefficient for normalization
        P0 = @(r,Fc,D) (Fc^2- r^2)/(-2*r*D); 
        % see '(2020) Solve SDE for DRY friction.mw'
        if nargin == 0
            return
        elseif nargin == 3
            P0 = P0(varargin{:});
        else
            error('invalid number of input argument');
        end
    end
    
    function [FitFunction] = Pst(varargin)
        % see Wu2020 (not submit yet)
        FitFunction = @(P0,r,Fc,D,v) P0*exp(Fc*v/D).*exp(-r*v.*sign(v)/D);
        if nargin == 0
            return
        elseif nargin == 4
            FitFunction = FitFunction(varargin{:});
        else
            error('invalid number of input argument');
        end
    end
    
    
%     function [FitFunction] = Pst2()
%         % This way failed.
%         P0 = Eq.FkP.CoulombWithFext.P0;
%         FitFunction = @(v,r,Fc,D) P0(r,Fc,D)*exp(Fc*v/D).*exp(-r*v.*sign(v)/D);
%     end
    
    function [f_neg,f_pos] = Pst_cases(varargin) % another equivalent form of Pst_CoulombFext_Wu2020
        f_neg = @(P0,r,Fc,D,v) P0*exp((Fc + r)*v/D); % for v <= 0
        f_pos = @(P0,r,Fc,D,v) P0*exp((Fc - r)*v/D); % for v > 0
        if nargin == 0
            return
        elseif nargin == 4
            f_neg = f_neg(varargin{:});
            f_pos = f_pos(varargin{:});
        else
            error('invalid number of input argument');
        end
    end
    
    function [TEX_neg,TEX_pos] = trPst_cases(varargin)
        fn = @(P0,r,Fc,D,v) P0*exp((Fc + r)*v/D); % f_neg, for v <= 0
        fp = @(P0,r,Fc,D,v) P0*exp((Fc - r)*v/D); % f_pos, for v > 0
        int_fn = @(P0,r,Fc,D,v) P0*D/(Fc+r)*exp((Fc + r)*v/D); % integral form
        int_fp = @(P0,r,Fc,D,v) P0*D/(Fc-r)*exp((Fc - r)*v/D);
        Pin = @(vmin,vmax,P0,r,Fc,D) (int_fn(P0,r,Fc,D,0) - int_fn(P0,r,Fc,D,vmin)) + (int_fp(P0,r,Fc,D,vmax)- int_fp(P0,r,Fc,D,0));
        TEX_neg = @(vmin,vmax,P0,r,Fc,D,v) fn(P0,r,Fc,D,v)/Pin(vmin,vmax,P0,r,Fc,D);
        TEX_pos = @(vmin,vmax,P0,r,Fc,D,v) fp(P0,r,Fc,D,v)/Pin(vmin,vmax,P0,r,Fc,D);
%         f_pos = @(v,P0,r,Fc,D) P0*exp((Fc - r)*v/D)/(((P0*D/(Fc+r)-P0*D/(Fc+r)*exp((Fc + r)*vmin/D))-()); % for v > 0

        if nargin == 0
            return
        elseif nargin == 7
            TEX_neg = TEX_neg(varargin{:});
            TEX_pos = TEX_pos(varargin{:});
        else
            error('invalid number of input argument');
        end
    end
%     P0*D/(Fc-r)*exp((Fc - r)*v/D)-P0*D/(Fc-r)


%     case 'GRlaw'
%     function FitFunction = GRlaw()
%         FitFunction = @(a,b,t) 10.^(a-b*(2/3)*log10(t)-6.07);
%     end



end
end

