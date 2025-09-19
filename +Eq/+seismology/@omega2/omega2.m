classdef omega2
    % OMEGA2  Collection of omega-squared style spectral models.
    % (2025 refactor) Added PSD variants *_PSD returning A/(1+(f/fc)^2)
    % for direct fitting to Welch PSD estimates; see guide
    % gpt5-fix-matlab-code-CHECKPOINT.md for rationale (avoid bias from
    % amplitude fitting & unequal per-decade weighting).
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
        function model_Ide_PSD = Ide2019Eq4_PSD()
            % Power spectral density (PSD) form corresponding to Ide2019Eq4
            % Amplitude model:  A / sqrt(1 + (f/fc)^2)
            % PSD model:        P(f) = Apsd / (1 + (f/fc)^2)
            % (Simply the square of the amplitude form with Apsd = A^2.)
            % Using a dedicated function allows direct fitting of PSD
            % estimates (e.g., Welch) without having to square-root.
            model_Ide_PSD = @(c,f) c(1) ./ (1 + (f./c(2)).^2); % c = [Apsd, fc]
        end
        function model_Aki_PSD = Aki1967Eq30_PSD()
            % PSD form for the classic omega-square / Aki model.
            % Provided for symmetry and clarity (identical functional
            % form to Ide2019Eq4_PSD but kept separate for readability
            % and potential future divergence).
            model_Aki_PSD = @(c,f) c(1) ./ (1 + (f./c(2)).^2); % c = [Apsd, fc]
        end
    end
end