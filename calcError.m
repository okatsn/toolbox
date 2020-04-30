function [Results] = calcError(Y1_data,Y2_true,varargin)
% function [Results,function_varargin] = inputParser2(function_varargin,NameOnly_cell,varargin)
NameOnly_cell = {'rmse','mse','rsquared'};
[Results,varargin] = inputParser2(varargin,NameOnly_cell);

if Results.rmse
    Results.rmse = sqrt(mean((Y1_data - Y2_true).^2));  % Root Mean Squared Error
end

if Results.mse
    Results.mse = mean((y - yhat).^2);   % Mean Squared Error
end

if Results.rsquared
% mdl = fitlm(X,y) returns a linear regression model of the responses y, fit to the data matrix X.
% mdl.Rsquared.Adjusted
% mdl.Rsquared.Ordinary
% https://www.mathworks.com/help/stats/coefficient-of-determination-r-squared.html
%     mdl = fitlm(Y1_data,Y2_true); %returns a linear regression model of the responses y, fit to the data matrix X.
observed_value = Y1_data;
pred_value = Y2_true;
Ybar = mean(observed_value);
SS_tot = nansum((observed_value - Ybar) .^ 2);
SS_res = nansum((observed_value - pred_value) .^ 2);
Results.rsquared = 1 - SS_res/SS_tot;

end
    
    
end

