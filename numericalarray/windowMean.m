function varargout = windowMean(varargin)
% windowMean calculates the average of Y in non-overlapped windows. 
% The next window is just right after the previous one side by side.
% windowMean is similar to windowAverage with additional options to assign final points,
% but not support matfile yet. windowMean and windowAverage should be
% merged one day.
% How to use:
%     Y_smoothed = windowMean(Y);
%     [X_smoothed,Y_smoothed] = windowMean(X,Y);
%     [X_smoothed,Y_smoothed,Z_smoothed] = windowMean(X,Y,Z);
%     ...,etc.
% 
%     windowMean(__,'WindowLength',windowLength);
%         mean over the values in every window given a fixed window length.
%     windowMean(__,'OutputPoints',totalPoints);
%         mean over the values in every window given a final output point.
%         (i.e. numel(Y_smoothed) is totalPoints).

ischararray = cellfun(@ischar,varargin);
indFirstName = find(ischararray,1); % return the 1st index of name-value pair.
if isempty(indFirstName) % no name value pair
    error("You should specify either 'WindowLength' or 'OutputPoints'");
end
varargin2 = varargin(indFirstName:end);
varargin(indFirstName:end) = [];
p = inputParser;
% p.KeepUnmatched = 1; % keep unmatched name-value pair
addParameter(p,'WindowLength',0);
addParameter(p,'OutputPoints',0);
parse(p,varargin2{:});
wLength = p.Results.WindowLength;
oPoints = p.Results.OutputPoints;

numvars = length(varargin); % number of variables
lenvars = cellfun(@length,varargin); % lengths of variables
diff_lenvars = diff(lenvars); 
% lengths of variables should has no difference, hence their sum should be
% zero.
if sum(diff_lenvars)>0
    error('Input variables should be arrays of the same length');
end

if oPoints == 0
    oPoints = ceil(lenvars(1)/wLength);
else % if wLength == 0
    wLength = ceil(lenvars(1)/oPoints);
end
remoutwindow = rem(lenvars(1),wLength);
if remoutwindow~=0
    numNaN = wLength - remoutwindow;
else
    numNaN = 0;
end
nanArray = NaN(numNaN,1);
vars_NaNFilled = cellfun(@(X) [X(:);nanArray], varargin, 'UniformOutput', false);
vars_reshaped = cellfun(@(X) reshape(X,wLength,oPoints), vars_NaNFilled, 'UniformOutput', false);
vars_mean = cellfun(@(X) nanmean(X,1), vars_reshaped, 'UniformOutput', false);
varargout = vars_mean;
end

