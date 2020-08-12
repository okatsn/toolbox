function [varargout] = RSS(varargin)
% calculate the RSS (residual sum of squares)
% RSS_out = RSS(MSE_in); % input the mean squared error MSE_in
% [RSS, MSE, R2] = RSS(predictions,data); % R2 is the R-squared

lenargin1 = length(varargin{1});
if lenargin1 == 1
    MSE_out = varargin{1};
    RSS_out = MSE_out*lenargin1;
elseif lenargin1 == length(varargin{2})
    predictions = varargin{1};
    data = varargin{2};
    RSS_out = sum((data - predictions).^2);
    MSE_out = RSS_out/lenargin1;
end

varargout{1} = RSS_out;
if nargout > 1
    varargout{2} = MSE_out;    
    if nargout >2
        if isscalar(varargin{2})
            meandata = varargout{2};
        else
            meandata = mean(data);
        end
        TSS = sum((data - meandata).^2);
        R2 = 1 - RSS_out/TSS;
        varargout{3} = R2;
    end
end



end

