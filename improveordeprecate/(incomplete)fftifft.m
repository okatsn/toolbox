function [outputArg1,outputArg2] = fftifft(t,x,varargin)
if nargin>1
    freqRange = varargin{:};
end
%% Definitions
Fs=1/(t(2)-t(1)); %sampling freq
N=length(x);
Nfft=2^nextpow2(N);
f=Fs/2*linspace(0,1,1+Nfft/2); % create freqs vector
cutoff_freq=Fs/8;


y=fft(x,Nfft)/N; % perform fft transform
y2=filterfft(f, y, cutoff_freq, my_freqs); % filter amplitudes
%X=ifft(y2,'symmetric'); % the inverse transform. 'symmetric' is not recognized in older versions of matlab 
X=ifft(y2); % inverse transform
X=X(1:N)/max(X);


end

