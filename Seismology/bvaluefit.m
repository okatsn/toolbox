function [a_b_array,varargout] = bvaluefit(y,varargin)
% Calculate the slopes for different segments in log-log plot.
% Typical scenerio: get the b-value in Magnitude-Frequency plot.
% If the result is bad, try to remove strange values before bvaluefit.
% How to use:
% 1. Basic/in general
%     1-1 non-linear fit
%         % fit function for Energy v.s. Duration plot
%         func1 = @(c,y)exp(c(1)+c(2)*log(y)); 
%         bvaluefit(Es,duration_sec,'ModelFunction',func1,);
%
% 2. find the b-value (Gutenberg-Richter law)
%     G-R law: logN(>m) = -bm + a
%     
%     [a_b_array,m,ccdfm] = bvaluefit(Es,'GRLaw','MomentMagnitude'); 
%     % Es are in unit N*m, with m being the moment magnitude.
%     % That is, Es will be converted into seismic moment M0 according to
%     % Mw = @(Es) 2/3*log10(Es) - 6.07 % (Kanamori 2004)
% 
%     [a_b_array,m,ccdfm] = bvaluefit(A_max,C,'GRLaw','LocalMagnitude'); 
%     % A_max are the largest amplitude, with m being local magnitude.
%     % That is, m = M_L = @(A_max,C) log10(A) - C.
%     % C is an optional constant, conventionally C = log10(A0(delta)).
%
% 3. Provide other initial guess. Normally default guess works fine for G-R law plot.
%     bvaluefit(...,'InitialGuess',[2,0.5]); % [a0,b0] for 10.^(a-b*log10(y));
%
% 4. Padding in each pieces of curve to get better fitting
%     bvaluefit(...,'Padding',0.1);
%     % 10% of total elements (in head) and 10% (in tail) of each segment/piece are ignored before fitting.
%     bvaluefit(...,'Padding',[0.1,0.2]);
%     % 10% of total elements (in head) and 20% (in tail) of each segment/piece are ignored before fitting.
%     bvaluefit(...,'Padding',[0.1, 0.1;0.1,0.2]);
%     % 10% of total elements (in head) and 10% (in tail) of 1st segment/piece are ignored before fitting.
%     % 10% of total elements (in head) and 20% (in tail) of 2nd segment/piece are ignored before fitting.
%
% 5. Plot the predicted lines according to the fitting result
%      bvaluefit(...,'loglogPlot',1);
%
% 6. Split input array into segments and fit separately
%     bvaluefit(...,'SegmentNumber',3); 
%     % devided the array into 3 segments and fit
%     bvaluefit(...,'SegmentNumber',[1,1e3,7e6]);
%     % split the array at y = 1, 1e3 and 7e6 (into 2 segments), and fit
a0 = 5;
b0 = 0.1; % InitialGuess

default_modelfun = @(c,y) 10.^(c(1)-c(2)*log10(y)); % 10.^(a-b*log10(y))
% default_modelfun = @(c,y) exp(c(1)-c(2)*log(y));

p = inputParser;
addOptional(p,'SecondArgument',0);
addParameter(p,'GRLaw',0);
addParameter(p,'SegmentNumber',2);
addParameter(p,'ModelFunction',default_modelfun);
addParameter(p,'InitialGuess',[a0,b0]);
addParameter(p,'Padding',0.05); % padding in y_range before fitting
addParameter(p,'Plot',0);
% Typically there will be two segments of different 'slope' (the flat one and the one that is the b-value).

parse(p,varargin{:});

secArg = p.Results.SecondArgument;
use_GRLaw = p.Results.GRLaw;
modelfun = p.Results.ModelFunction;
numclusters = p.Results.SegmentNumber;
beta0 = p.Results.InitialGuess; % initial guess
do_plot = ~isequal(p.Results.loglogPlot,0);
Padding = p.Results.Padding;
[hP,wP] = size(Padding);
logbeforekmeans = true;


if ~isequal(use_GRLaw,0)
    logbeforekmeans = false;
    modelfun = @(c,m) 10.^(c(1)-c(2)*m); % 10.^(a-b*m)
    switch use_GRLaw
        case 'MomentMagnitude'
            Mw = @(Es) 2/3*log10(Es) - 6.07; % (Kanamori 2004)
            [cdfY,y] = cdfE(Mw(y)); % y should be in unit N*m
            ccdfY = 1-cdfY;
        case 'LocalMagnitude'
            C = secArg;
            ML = @(A_max,C) log10(A) - C;
            [cdfY,y] = cdfE(ML(y,C)); % y should be the largest magnitudes
            ccdfY = 1-cdfY;
        otherwise
        error('Incorrect input value for GRLaw.')
    end
else
    ccdfY = secArg;
end

y = y(:);
ccdfY = ccdfY(:);
leny =length(y);

[ys, ind2sorted] = sort(y); % y(ind2sorted) = ys.
ccdfYs = ccdfY(ind2sorted);
%% this section is superfluous and can be delete in the future.
if ~isequal(ys,y) || ~isequal(ccdfYs,ccdfY)
    disp('y and Y is sorted before nlinfit.')
    y = ys;
    ccdfY = ccdfYs;
end
clear('ys','ccdfYs');

%% define edges for clusters
manually_split = ~isscalar(numclusters);
if manually_split
    % if numclusters is not a scalar, but an array such as: [1, 100, 999]
    % that will split the whole input into two segments, y(1:100),
    % y(100:999) and do fitting separately. 
    % (This example is for y = 1:999 that y(i) is exactly i.)
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



if logbeforekmeans
    % diff_log_ccdfY = diff(log10(ccdfY));% log(y_{i+1}) - log(y_{i}) = log( y_{i+1}/y_{i} )
    log_ccdfY = log10(ccdfY);
    log_y = log10(y);
    % figure; plot(log_y(2:end),diff_log_ccdfY,'o'); % just for visualization.
    % figure; plot(log_y(3:end),diff(log(diff_log_ccdfY)),'o'); % just for visualization.


    % X = [log_y,diff_log_ccdfY];
    X = [log_y,log_ccdfY];
else
    X = [y,ccdfY];
end

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
        plot(yi,pred_ccdfYi,'--');

    end
    
end

if nargout>1 % 2nd output
    varargout{1} = y;
    if nargout>2 % 3rd output argument
        varargout{2} = ccdfY;
    end
end

end

