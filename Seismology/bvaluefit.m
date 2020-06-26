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
%  5. Split input array into segments and fit separately
%     bvaluefit(...,'SegmentNumber',3); 
%     % devided the array into 3 segments and fit
%     bvaluefit(...,'SegmentNumber',[1,1e3,7e6]);
%     % split the array at y = 1, 1e3 and 7e6 (into 2 segments), and fit
a0 = 5;
b0 = 0.1; % InitialGuess

default_modelfun = @(c,y) 10.^(c(1)-c(2)*log10(y)); % 10.^(a-b*log10(y))
% default_modelfun = @(c,y) exp(c(1)-c(2)*log(y));

p = inputParser;
addParameter(p,'SegmentNumber',2);
addParameter(p,'ModelFunction',default_modelfun);
addParameter(p,'InitialGuess',[a0,b0]);
addParameter(p,'Padding',0.05); % padding in y_range before fitting
addParameter(p,'loglogPlot',0);
% Typically there will be two segments of different 'slope' (the flat one and the one that is the b-value).

parse(p,varargin{:});

modelfun = p.Results.ModelFunction;
numclusters = p.Results.SegmentNumber;
beta0 = p.Results.InitialGuess; % initial guess
do_plot = ~isequal(p.Results.loglogPlot,0);
Padding = p.Results.Padding;
[hP,wP] = size(Padding);

manually_split = ~isscalar(numclusters);
if manually_split
    % if numclusters is not a scalar, but an array such as: [1, 100, 999]
    % that will split the whole input into two segments, y(1:100),
    % y(100:999) and do fitting separately.
    edges = nearest1d(y,numclusters);
    numclusters = length(numclusters) - 1;
end

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


y = y(:);
ccdfY = ccdfY(:);

% diff_log_ccdfY = diff(log10(ccdfY));% log(y_{i+1}) - log(y_{i}) = log( y_{i+1}/y_{i} )
log_ccdfY = log10(ccdfY);
log_y = log10(y);
% figure; plot(log_y(2:end),diff_log_ccdfY,'o'); % just for visualization.
% figure; plot(log_y(3:end),diff(log(diff_log_ccdfY)),'o'); % just for visualization.


% X = [log_y,diff_log_ccdfY];
X = [log_y,log_ccdfY];

if numclusters > 1 && ~manually_split
    clusteridx = kmeans(X,numclusters); 
    splitpoint = find(diff(clusteridx)); 
    expected_n = numclusters-1;
    if length(splitpoint) > expected_n
    % ideally, clusteridx should be such as 1 1 1 2 2 2...
    % and hence we can use diff to find the splitpoint (at 3 for this case).
    % However, sometimes it's not ideal and may gives such as 1 1 2 1 2 2...,
    % and consequently find(diff(clusteridx)) gives splitpoint as 2,3,4.
    % We hence sort and take average on these superfluous split points.
        splitpoint = sort(splitpoint);
        splitpoint_ext = extendToMMultiples(splitpoint,expected_n);
        splitpoint_reshape = reshape(splitpoint_ext,[],expected_n);
        splitpoint = nanmean(splitpoint_reshape,1);
    end
    edges = [1,splitpoint,leny];
elseif ~manually_split
    edges = [1,leny];
else % manually_split
    % do nothing
end

a_b_array = NaN(numclusters,length(beta0));

for i = 1:numclusters
    yrangepad = floor(leny*Padding(i,:));
%     yrange = edges(i:i+1) + yrangepad;
    ystartend = edges(i:i+1) + yrangepad; % bug fixed 2020.06.20
    yrange = ystartend(1):ystartend(2);
    yi = y(yrange);
    ccdfYi = ccdfY(yrange);
    beta0_i = beta0_array(i,:);
    a_b_array(i,:) = nlinfit(yi,ccdfYi,modelfun,beta0_i);
end

if do_plot
    for i = 1:numclusters
%         yrange = edges(i:i+1);
        ystartend = edges(i:i+1); % bug fixed 2020.06.20
        yrange = ystartend(1):ystartend(2);
        yi = y(yrange);
        pred_ccdfYi = modelfun(a_b_array(i,:),yi);
        loglog(yi,pred_ccdfYi,'--');

    end
    
end

end

