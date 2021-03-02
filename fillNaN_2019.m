function [Y0] = fillNaN_2019(Y0)
% replace NaNs with linear interpolation dithered by noise.
% This function is used in CWB MagTIP project only.
% ????O?S???D?F??warning('fillNaN may need some attention (about the X, Xmissing in interp1. Check doc interp1)');
% Y0 = YBeforeDetrend';
[NoY, NoC] = size(Y0);
if size(Y0,1) ==1
    Y0 = Y0';
    NoY = NoC;
end

% Y0(2000:3000) = NaN;
% Y0(70000:80000) = NaN;

Y = Y0;

X0 = [1:NoY]';
X = X0;

Xmissing = find(isnan(Y));
% Xmissing = [2,3,5:10,17:18,22:25,29]';
Y(Xmissing) = [];
X(Xmissing) = [];
Yintp = interp1(X,Y,Xmissing,'linear');
% figure;
% plot(X,Y,'bo')
% hold on
% plot(Xmissing,Yintp,'ro');


NoInt = length(Yintp);
std1 = 0.02;
Y0(Xmissing) = Yintp + std1*randn(NoInt,1);
% figure; plot(X0,Y0,'o');
% hold on 
% plot(X,Y);
% 
% bdryInd = diff(Xmissing);
% bdryInd(bdryInd ==1) = 0; % dY = 1, then it is not a boundary point (indexed at the 2nd one)
% bdryInd(bdryInd ~=0) = 1;
% bdryInd(find(bdryInd == 1) - 1) = 1; 
% bdryInd = [1;bdryInd];
end

