%% demo fft
dt = 1e-3;
t0 = 0:dt:1.5; % in unit second
freqs = [200, 300]; % Hz
wavenumber = @(f) 2*pi*f; % the (angular) wavenumber k = 2*pi/lambda = 2*pi*f
lambda = @(k) 2*pi/k;% gives wavelength (period of the wave)
freq = @(k) 1/lambda(k);% gives the frequency f = 1/lambda


lgd = @(k) sprintf('sin(%d*pi*t); f = %.2f Hz; T = %.2f',k/pi,freq(k),lambda(k));  % legend

k1 = wavenumber(freqs(1)); 
k2 = wavenumber(freqs(2)); 
s1 = sin(k1*t0); % real data (component 1)
s2 = sin(k2*t0); % real data (component 2)
X = s1 + s2 + 0.1*randn(size(t0)); % observed signal


% 假設取樣頻率為Fs，訊號頻率F，取樣點數為N。那麼FFT之後結果就是一個為N點的複數。
Fs = 1/dt; % sampling rate (sampling frequency)
T = 1/Fs; % sampling period. That is, dt.
L = length(t0); % Length of signal
t = (0:L-1)*T; % Time vector. It should be the same (or almost the same) as t0.

if length(t) == length(t0) && max(t-t0) < 1e-13
    disp('As expected.')
else
    warning('something goes wrong.')
end

Y = fft(X);
P2 = abs(Y/L); % two-sided spectrum
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1); % Single-Sided Amplitude Spectrum of X(t)
f = Fs*(0:(L/2))/L;

figure;
m = 3;
subplot(m,1,1)
maxlambda = max(lambda(k1),lambda(k2));
ids = t0<6*maxlambda; % only show the segment indicated by this set of indices 
plot(t0(ids),s1(ids));
hold on
plot(t0(ids),s2(ids));
legend({lgd(k1),lgd(k2)})
grid on
title({'true data',sprintf('sampling rate: %e',Fs)});
% set(gca,'XTick',t0(1):0.1:t0(end));
subplot(m,1,2)
plot(t,X);
xlabel('t (sec)')
title('observed data (true data dithered with noise)');
subplot(m,1,3)
plot(f,P1);
xlabel('f (Hz)')
ylabel('|P1(f)|')
title(sprintf('(maximum frequency resolution: %d Hz)',max(f)));
ax = gca;
ax.XTick = unique(sort([ax.XTick,freqs]));
ax.XTickLabelRotation = 45;
%%
% N: total number of sample points. N = 2^M where M \in integer
% Fn所能分辨到頻率為為Fs/N，如果取樣頻率Fs為1024Hz，取樣點數為1024點，則可以分辨到1Hz。
% 1024Hz的取樣率取樣1024點，剛好是1秒，也就是說，取樣1秒時間的訊號並做FFT，
% 則結果可以分析精確到1Hz，如果取樣2秒時間的訊號並做FFT，則結果可以分析精確到0.5Hz。
% 根據Nyquist取樣定理，FFT之後的頻譜寬度（Frequency Span）最大隻能是原始訊號取樣率的1/2，
% 如果原始訊號取樣率是4GS/s，那麼FFT之後的頻寬最多隻能是2GHz
% https://www.itread01.com/content/1545271337.html
dt = 1e-4; % sampling period
t0 = [0:dt:1.5]'; % in unit second
freqs = [50, 200, 300, 450]; % frequencies of sin waves in unit Hz
amps = [0.2, 0.5, 0.5, 0.9]; % amplitudes of the sin waves
Fs = 1/dt; % sampling rate (sampling frequency)


wavenumber = @(f) 2*pi*f; % the (angular) wavenumber k = 2*pi/lambda = 2*pi*f
lambda = @(k) 2*pi./k;% gives wavelength (period of the wave)
freq = @(k) 1./lambda(k);% gives the frequency f = 1/lambda

k = wavenumber(freqs);
ka = repmat(k,length(t0),1);
ta = repmat(t0,1,length(freqs));
amps_a = repmat(amps,length(t0),1);
s = amps_a.*sin(ka.*ta);
X = sum(s,2) + 0.1*randn(size(t0)); % observed signal
[f,P1,P2] = lazy_fft(X,t0);

lgdfun = @(k,a) sprintf('%.2f*sin(%d*pi*t); f = %.2f Hz; T = %.2f',a,k/pi,freq(k),lambda(k));
lgd = cellfun(lgdfun,num2cell(k),num2cell(amps),'UniformOutput',false);
figure;
m = 3;
subplot(m,1,1)
maxlambda = max(lambda(k));
ids = t0<6*maxlambda; % only show the segment indicated by this set of indices 
plot(t0(ids),s(ids,:));
% xtick1 = t0(ids);
% set(gca,'XTick',xtick1);
legend(lgd)
grid on
title({'true data',sprintf('sampling rate: %e',Fs)});
% set(gca,'XTick',t0(1):0.1:t0(end));
subplot(m,1,2)
plot(t0,X);
xlabel('t (sec)')
title('observed data (true data dithered with noise)');
subplot(m,1,3)
plot(f,P1);
xlabel('f (Hz)')
ylabel('|P1(f)|')
title(sprintf('(maximum frequency resolution: %d Hz)',max(f)));
ax = gca;
ax.XTick = unique(sort([ax.XTick,freqs]));
ax.XTickLabelRotation = 45;
ax.XLim = [0, 1.1*max(freqs)];
grid on
