function [ O ] = PowerFit5( X1,Y1,beta0 )
%利用fitnlm進行非線性擬合


%'StartPoint' 只在方法是 'NonlinearLeastSquares' 可以設定
%%%%%%%%%%%%%% (For fit) (FIT方法一)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FitDataX=X1;
FitDataY=Y1; %FitData has to be 1*m array( only 1 row)
FitFunc=@(a,x) a(1)*x.^a(2) ; %
%FitFunc=@(a,x) a(1)+a(2)*x.^a(3) ; % other.beta0=[1 1 1] %建設中，運作失常

% other.beta0=[1 1];%盡可能猜a(1)和a(2)最可能接近的值是多少。

mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0);

%opts = statset('nlinfit');  opts.RobustWgtFun = 'bisquare';% Robust fit 法I
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'Options',opts);% Robust fit 法I (給outlier很低的權重。)
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'ErrorModel','combined');% Robust fit 法II
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'ErrorModel','proportional');% Robust fit 法III
%','Exclude',FitDataX>100  %排除掉超過100的值。
a=mdl.Coefficients.Estimate;


slope=a(2);
intercept = log10(a(1));
p=[slope intercept];

rightBound=log10(1.1*max(FitDataX));
leftBound=log10(0.9*min(FitDataX));
ex = logspace(leftBound,rightBound,100); % 從10^leftBound到10^rightBound之間建立100個指數等間距的向量
yy = a(1)*ex.^a(2);%擬合函數

%        estY=a(1)*FitDataX.^a(2); % the estimate of the 'y' value for each point.
%       MSE = mean((FitDataY-estY).^2); % mean squared error.
%O.MSE=MSE;
%O.rmse=sqrt(MSE);


O.MSE=mdl.MSE;
O.rmse=mdl.RMSE;
O.slope=slope;
O.intercept=intercept;
O.PolyCoeff=p;

%Plot the data
plot(ex,yy,'-');
hold('on'); % in case hold off was on before

% Plot the approximate line



end

