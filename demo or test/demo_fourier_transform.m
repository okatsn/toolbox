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


% ���]�����W�v��Fs�A�T���W�vF�A�����I�Ƭ�N�C����FFT���ᵲ�G�N�O�@�Ӭ�N�I���ƼơC
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
% Fn�ү������W�v����Fs/N�A�p�G�����W�vFs��1024Hz�A�����I�Ƭ�1024�I�A�h�i�H�����1Hz�C
% 1024Hz�����˲v����1024�I�A��n�O1��A�]�N�O���A����1��ɶ����T���ð�FFT�A
% �h���G�i�H���R��T��1Hz�A�p�G����2��ɶ����T���ð�FFT�A�h���G�i�H���R��T��0.5Hz�C
% �ھ�Nyquist���˩w�z�AFFT���᪺�W�мe�ס]Frequency Span�^�̤j����O��l�T�����˲v��1/2�A
% �p�G��l�T�����˲v�O4GS/s�A����FFT���᪺�W�e�̦h����O2GHz
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
