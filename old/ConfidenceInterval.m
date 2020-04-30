% In order to calculate the 95% confidence intervals of your signal, 
% you first will need to calculate the mean and *|std| (standard deviation) 
% of your experiments at each value of your independent variable. 
% The standard way to do this is to calculate the standard error 
% of the mean at each value of your independent variable, 
% multiply it by the calculated 95% values of the t-distribution (here), 
% then add and subtract those values from the mean. The plot is then straightforward. 
% (The tinv function is in the Statistics and Machine Learning Toolbox.)
% https://www.mathworks.com/matlabcentral/answers/414039-plot-confidence-interval-of-a-signal?s_tid=answers_rc1-2_p2_MLT

x = 1:100;                                          % Create Independent Variable
y = randn(50,100);                                  % Create Dependent Variable ．Experiments・ Data
N = size(y,1);                                      % Number of ．Experiments・ In Data Set
yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ．x・
ySEM = std(y)/sqrt(N);                              % Compute ．Standard Error Of The Mean・ Of All Experiments At Each Value Of ．x・
CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ．x・
figure
plot(x, yMean)                                      % Plot Mean Of All Experiments
hold on
plot(x, yCI95+yMean)                                % Plot 95% Confidence Intervals Of All Experiments
hold off
grid