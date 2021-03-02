% Key functions: designfilt, fftfilt, gpuDevice, gpuArray, gather, reset
% Advanced topics: Run MATLAB Functions on Multiple GPUs
Fs = 1;
t = 0:1/Fs:86400-(1/Fs);
x = cos(2*pi*0.1*t) + 0.5*sin(2*pi*0.3*t) + 0.25*cos(2*pi*0.35*t)+ ...
    0.125*sin(2*pi*0.4*t);
x = repmat(x', [1, 365]);

lpfir_filter = designfilt('lowpassfir','SampleRate',Fs, ...
    'PassbandFrequency', 0.2, 'StopbandFrequency', 0.3, ...
    'PassbandRipple', 0.5,'StopbandAttenuation', 60);
% fvtool(d)  % view filter
B = lpfir_filter.Coefficients;  

tic;
y = fftfilt(B, x);
toc;

% Query or select a GPU device
d = gpuDevice;
d.ComputeMode
tic;
% gpuArray: 
%   Array stored on GPU
%   That is, RAM to VRAM (Video RAM)
% gather:
%   Transfer distributed array or gpuArray to local workspace
%   That is, VRAM to RAM
y = gather(fftfilt(gpuArray(B), gpuArray(x)));
toc;
% Reset GPU device and clear its memory
reset(d);
% deselects the GPU device and clears its memory of gpuArray and CUDAKernel variables
gpuDevice([]);