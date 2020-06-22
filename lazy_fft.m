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
% Plot:
%     plot(f,P2(1:n/2+1));% Plot the unique frequencies. see doc fft.
%     plot(f,P1);

fft_input = {X};
if length(t0)>1 % then t0 is the timeseries
    dt = t0(2)-t0(1); % sampling period T
    L = length(t0); % Length of signal
    if nargin>2 % Y = lazy_fft(X,t,n);
        n = varargin{1};
        fft_input = [fft_input, {n}];
    else % Y = lazy_fft(X,t);
        n = L;
    end
    
else % if length(t0) == 1, then t0 should be the samping period, dt.
    dt = t0;
    L = varargin{1}; % if 2nd argument is sampling period (T), then signal length L is required.
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
P2 = abs(Y/L); % two-sided spectrum

% Compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P1 = P2(1:n/2+1); % P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1); % Single-Sided Amplitude Spectrum of X(t)

% Define the frequency domain f
f = Fs*(0:(n/2))/n; % f = Fs*(0:(L/2))/L;
% because the indices of P1 is 1:(n/2+1), 
% hence f = 0:(n/2) has the same number of elements of P1.
% On the other hand, to plot P1(1:n/2), the correct size of f is 0:(n/2-1).
% Just making a note, 0:(Fs/n):(Fs/2-Fs/n) in the documents of fft 
% is identical to Fs*(0:(n/2-1))/n.
end

