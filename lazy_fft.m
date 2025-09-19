function [f,P1,P2] = lazy_fft(X,t0,varargin)
% please also refer to demo_fourier_transform.m
% Y = lazy_fft(X,t);
%     X: the signal of size N by 1
%     t: the timeseries of size N by 1
% Y = lazy_fft(X,t,n);
%     returns the n-point DFT. If no value is specified, Y is the same size as X
% Y = lazy_fft(X,T,L);
%     X: the signal of size N by 1
%     T: the sampling period (a scalar)
%     L: the length of the signal (required only if 2nd argument is T)
% Y = lazy_fft(X,t,n,'SpectrumType','PSD');
%     Additional parameter 'SpectrumType' can be 'ASD' (default, legacy) or 'PSD'
%     ASD: Amplitude Spectral Density (backward compatible)
%     PSD: Power Spectral Density [units: var/Hz]
% Plot:
%     plot(f,P2(1:n/2+1));% Plot the unique frequencies. see doc fft.
%     plot(f,P1);
% Bug to fix: 1:n/2+1 will cause
%             Warning: Integer operands are required for colon operator when used as index
%% To demean:  use `X = X - mean(X);` as input

% Parse input arguments
p = inputParser;
addRequired(p, 'X');
addRequired(p, 't0');
addOptional(p, 'n_or_L', []);
addParameter(p, 'SpectrumType', 'ASD', @(x) ismember(x, {'ASD', 'PSD'}));

% Determine if we have name-value pairs
name_value_start = [];
for i = 1:length(varargin)
    if ischar(varargin{i}) && ismember(varargin{i}, {'SpectrumType'})
        name_value_start = i;
        break;
    end
end

if isempty(name_value_start)
    % No name-value pairs, parse as before
    if ~isempty(varargin)
        parse(p, X, t0, varargin{1});
    else
        parse(p, X, t0);
    end
else
    % Has name-value pairs
    if name_value_start > 1
        parse(p, X, t0, varargin{1}, varargin{name_value_start:end});
    else
        parse(p, X, t0, varargin{:});
    end
end

spectrum_type = p.Results.SpectrumType;
n_or_L_input = p.Results.n_or_L;

fft_input = {X};
if length(t0)>1 % then t0 is the timeseries
    dt = t0(2)-t0(1); % sampling period T
    L = length(t0); % Length of signal
    if ~isempty(n_or_L_input) % Y = lazy_fft(X,t,n);
        n = n_or_L_input;
        fft_input = [fft_input, {n}];
    else % Y = lazy_fft(X,t);
        n = L;
    end
    
else % if length(t0) == 1, then t0 should be the samping period, dt.
    dt = t0;
    L = n_or_L_input; % if 2nd argument is sampling period (T), then signal length L is required.
    n = L;
end


Fs = 1/dt; % sampling rate (sampling frequency)
% T = 1/Fs; % sampling period. That is, dt.


%% remove this section someday
t = (0:L-1)*dt; % Time vector. It should be the same (or almost the same) as t0.
if length(t) == length(t0)
    %     disp('As expected.')
else
    warning('something goes wrong.')
end

%% doing fft
Y = fft(fft_input{:});

% Choose spectrum type based on input parameter
switch spectrum_type
    case 'ASD'
        % Legacy behavior: Amplitude Spectral Density
        P2 = abs(Y/n); % two-sided amplitude spectrum
        spectrum_label = 'Single-Sided Amplitude Spectrum of X(t)';
    case 'PSD'
        % New behavior: Power Spectral Density
        P2 = (abs(Y).^2) / (Fs*n);      % two-sided PSD [units: var/Hz]
        spectrum_label = 'one-sided PSD';
end

% Compute the single-sided spectrum P1 based on P2 and the signal length.
% Use floor(n/2) to avoid non-integer indexing warnings when n is odd.
nhalf = floor(n/2);
P1 = P2(1:nhalf+1); % P1 = P2(1:L/2+1);

if numel(P1) > 2
    P1(2:end-1) = 2*P1(2:end-1);  % Apply factor for one-sided spectrum
end

% Define the frequency domain f
f = (0:nhalf) * (Fs/n);          % Hz
% because the indices of P1 is 1:(n/2+1),
% hence f = 0:(n/2) has the same number of elements of P1.
% On the other hand, to plot P1(1:n/2), the correct size of f is 0:(n/2-1).
% Just making a note, 0:(Fs/n):(Fs/2-Fs/n) in the documents of fft
% is identical to Fs*(0:(n/2-1))/n.
end

