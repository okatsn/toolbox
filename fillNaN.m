function [Y0] = fillNaN(Y0)
% replace NaNs with linear interpolation dithered by noise.

Y0 = Y0(:);
NoY = length(Y0);
Y = Y0;

X0 = [1:NoY]';
X = X0;

YisNaN = isnan(Y);
Y(YisNaN) = [];
X(YisNaN) = [];
XmissingInd = YisNaN; % ~ismember(X0,X);
Xintp = X0(XmissingInd); 

std1 = nanmedian(movstd(Y0,250)); % to estimate the std for the nosie.
if isnan(std1)
    std1 = nanmedian(Y0); % to estimate the std for the nosie
end
try
    Yintp = interp1(X,Y,Xintp,'linear');
catch ME
    if length(X)<2
        % Interpolation requires at least two sample points in each dimension.
        stillnan = isnan(Y0); % if NaN starts from the beginning, Y_intp is NaN, 
        Y0(stillnan) = nanmean(Y0) + std1*randn(sum(stillnan),1);
        return
    else
        warning("[fillNaN] Error in bandpass filtering.");
        % rethrow(ME);
    end
end
% figure; plot(X0,Y0,'o'); hold on; plot(Xintp,Yintp,'^')

NoInt = length(Yintp);
Y0(XmissingInd) = Yintp + std1*randn(NoInt,1);

% Y0(XmissingInd) = Yintp;
% Y0 = addNoise(Y0,XmissingInd);

% because Yintp will be NaN if Xintp is not bounded with at least two
% non-NaN Y value. Therefore,
% if there is still nan remain:
stillnan = isnan(Y0); % if NaN starts from the beginning, Y_intp is NaN, 
if any(stillnan,'all')
    [TrueInd,FalseInd] = splitContinue10(stillnan);
    for i = 1:length(TrueInd)
        ind_i = TrueInd{i};
        Ind_ext = [ind_i(1)-1,ind_i(end)+1];
        isInd_ext_valid = Ind_ext > 0 & Ind_ext <= NoY;
        NearestValueInd = Ind_ext(isInd_ext_valid);
        NearestValueAvg = mean(Y0(NearestValueInd)); % find the average of the nearest valid value of Y.

        Y0(ind_i) = NearestValueAvg + std1*randn(length(ind_i),1);
    end
end

% and the corresponding Y0 dithered with noise remain nan since NaN + anything = NaN.
end

function Y = addNoise(Y,Ind)
% Y must be N by 1 array
numND = sum(Ind,'all'); % number of noise data
Y(Ind) = std1*randn(numND,1);
end