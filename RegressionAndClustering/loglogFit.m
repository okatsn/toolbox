function [ O ] = loglogFit( X,Y,varargin )
% fit X, Y to log(Y) = a*log(X) + b (i.e. Y = X^a)
% How to use:
%     O = loglogFit(X,Y);
%     O = loglogFit(X,Y,'plot');
%
%
% Output:
%     O.PolyCoeff = [a, b]
%     O.slope = a
%     O.intercept = b

% make this compatible with skipping some points.... don't know how yet....
% range=[min(X) max(Y)];
%        logRange=log10(range);
%        totRange=diff(logRange)+10*eps; % in case its all zeros...
%        logRange = [logRange(1)-totRange/20, logRange(2)+totRange/20];
%        ex = linspace(logRange(1),logRange(2),100); % note this is in log10 space

p = inputParser;
addParameter(p,'Plot',0);
parse(p,varargin{:});
plot_opt = p.Results.Plot;

if ~isequal(plot_opt,0)
    do_plot = true;
    if ~iscell(plot_opt)
        plot_opt = {plot_opt};
    end
else
    do_plot = false;
end

logX=log10(X);
logY=log10(Y);
%p = polyfit(x,y,n)%p為x的n次多項式前的係數，降冪排列
[p, ~] = polyfit(logX,logY,1);% logY=p(1)*logX+p(2)
slope=p(1);
intercept = p(2);

rightBound= max(logX);
leftBound = min(logX);
logX_pred = linspace(leftBound,rightBound,100); % note this is in log10 space
        
logY_pred = polyval(p,logX_pred);%yy=以p為係數的x的n次多項式；x以ex值帶入，yy為其對應的值
Y_pred=10.^logY_pred;
X_pred=10.^logX_pred;

%% calculate MSE 
estY = polyval(p,logX); % the estimate of the 'y' value for each point.
estY = 10.^estY; 
logY = 10.^logY;% need to do this for error estimation              
MSE = mean((logY-estY).^2); % mean squared error.
        
%% output
O.MSE=MSE;
O.rmse=sqrt(MSE);
O.slope=slope;
O.intercept=intercept;
O.PolyCoeff=p;
O.functionDescription = sprintf('log(Y) = %.2f*log(X) + %.2f',slope, intercept);
O.Y_pred = @(X) 10.^(slope*log(X) + intercept); % logY = slope*log(X) + intercept;

%% Plot the data
if do_plot
    plt = plot(X_pred,Y_pred,plot_opt{:});
    O.plotHandle = plt;
end
end

