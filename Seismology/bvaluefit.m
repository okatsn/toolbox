function [a_b_array] = bvaluefit(y,ccdfY,varargin)
% Calculate the slopes for different segments in log-log plot.
% Typical scenerio: get the b-value in Magnitude-Frequency plot.
% If the result is bad, try to remove strange values before bvaluefit.
% How to use:
% 1. Basic
%     [cdfY, y] = cdfE(Es,'EdgeScale','log');
%     ccdfY = 1-cdfY;
%     bvaluefit(y,ccdfY);
% 2. Provide other initial guess. Normally default guess works fine for G-R law plot.
%     bvaluefit(...,'InitialGuess',[2,0.5]); % [a0,b0] for 10.^(a-b*log10(y));
% 3. Padding in each pieces of curve to get better fitting
%     bvaluefit(...,'Padding',0.1);
%     % 10% of total elements (in head) and 10% (in tail) of each segment/piece are ignored before fitting.
%     bvaluefit(...,'Padding',[0.1,0.2]);
%     % 10% of total elements (in head) and 20% (in tail) of each segment/piece are ignored before fitting.
%     bvaluefit(...,'Padding',[0.1, 0.1;0.1,0.2]);
%     % 10% of total elements (in head) and 10% (in tail) of 1st segment/piece are ignored before fitting.
%     % 10% of total elements (in head) and 20% (in tail) of 2nd segment/piece are ignored before fitting.
%  4. Preview on the fitting result
%      bvaluefit(...,'loglogPlot',1);
a0 = 5;
b0 = 0.1;

p = inputParser;
addParameter(p,'SegmentNumber',2);
addParameter(p,'InitialGuess',[a0,b0]);
addParameter(p,'Padding',0.05); % padding in y_range before fitting
addParameter(p,'loglogPlot',0);
% Typically there will be two segments of different 'slope' (the flat one and the one that is the b-value).

parse(p,varargin{:});

numclusters = p.Results.SegmentNumber;
beta0 = p.Results.InitialGuess; % initial guess
do_plot = ~isequal(p.Results.loglogPlot,0);
Padding = p.Results.Padding;
[hP,wP] = size(Padding);

if wP == 1
    Padding = [Padding, -Padding];
else % wP >1
    Padding(:,2) = Padding(:,2)*-1;
end

if hP == 1
    Padding = repmat(Padding,[numclusters,1]);
end

if any(sum(abs(Padding),'all') > 1)
    error('Padding in different intervals of segments are too large.');
end

if size(beta0,1) == 1
    beta0_array = repmat(beta0,[numclusters,1]);
end

leny =length(y);
modelfun = @(c,y) 10.^(c(1)-c(2)*log10(y)); % 10.^(a-b*log10(y))
% modelfun = @(c,y) exp(c(1)-c(2)*log(y));

y = y(:);
ccdfY = ccdfY(:);

% diff_log_ccdfY = diff(log10(ccdfY));% log(y_{i+1}) - log(y_{i}) = log( y_{i+1}/y_{i} )
log_ccdfY = log10(ccdfY);
log_y = log10(y);
% figure; plot(log_y(2:end),diff_log_ccdfY,'o'); % just for visualization.
% figure; plot(log_y(3:end),diff(log(diff_log_ccdfY)),'o'); % just for visualization.


% X = [log_y,diff_log_ccdfY];
X = [log_y,log_ccdfY];

if numclusters > 1
clusteridx = kmeans(X,numclusters); 
splitpoint = find(diff(clusteridx));
edges = [1,splitpoint,leny];
else
    edges = [1,leny];
end

a_b_array = NaN(numclusters,length(beta0));

for i = 1:numclusters
    yrangepad = floor(leny*Padding(i,:));
    yrange = edges(i:i+1) + yrangepad;
    yi = y(yrange);
    ccdfYi = ccdfY(yrange);
    beta0_i = beta0_array(i,:);
    a_b_array(i,:) = nlinfit(yi,ccdfYi,modelfun,beta0_i);
end

if do_plot
%     figure;
%     loglog(y,ccdfY,'o');
%     hold on
    for i = 1:numclusters
        yrange = edges(i:i+1);       
        yi = y(yrange);
        pred_ccdfYi = modelfun(a_b_array(i,:),yi);
        loglog(yi,pred_ccdfYi,'--');

    end
    
end

end

