classdef omega2
    methods (Static)
        function model_Ide = Ide2019Eq4()
            model_Ide = @(c,f) c(1)./( sqrt(1+(f/c(2)).^2) );
            % Ide 2019 Eq.4
            %    (Ide 2019) Two-Dimensional Probabilistic Cell Automaton
            %    Model for Broadband Slow Earthquakes
        end
        function model_Aki = Aki1967Eq30()
            model_Aki = @(c,f) c(1)./( 1+(f/c(2)).^2 );
            % Lay, Eq. 10.38, p.515; Aki, 1967 Eq.30
            %    (Aki 1967) Scaling law of seismic spectrum
        end
        function model_PSD_Lorentzian = PSD_Lorentzian()
            % PSD fitting model: A/(1+(f/f_c)^2) - more appropriate for
            % single-pole processes to avoid bias from amplitude fitting
            model_PSD_Lorentzian = @(c,f) c(1)./( 1+(f/c(2)).^2 );
        end
        function model_PSD_Ide = PSD_Ide2019()
            % PSD fitting version of Ide model: A/(1+(f/f_c)^2)^0.5
            % This is P1^2 where P1 is the Ide amplitude model
            model_PSD_Ide = @(c,f) c(1)./( 1+(f/c(2)).^2 );
        end
    end
end