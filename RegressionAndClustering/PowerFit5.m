function [ O ] = PowerFit5( X1,Y1,beta0 )
%�Q��fitnlm�i��D�u�����X


%'StartPoint' �u�b��k�O 'NonlinearLeastSquares' �i�H�]�w
%%%%%%%%%%%%%% (For fit) (FIT��k�@)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FitDataX=X1;
FitDataY=Y1; %FitData has to be 1*m array( only 1 row)
FitFunc=@(a,x) a(1)*x.^a(2) ; %
%FitFunc=@(a,x) a(1)+a(2)*x.^a(3) ; % other.beta0=[1 1 1] %�س]���A�B�@���`

% other.beta0=[1 1];%�ɥi��qa(1)�Ma(2)�̥i�౵�񪺭ȬO�h�֡C

mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0);

%opts = statset('nlinfit');  opts.RobustWgtFun = 'bisquare';% Robust fit �kI
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'Options',opts);% Robust fit �kI (��outlier�ܧC���v���C)
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'ErrorModel','combined');% Robust fit �kII
%mdl = fitnlm(FitDataX,FitDataY,FitFunc,beta0,'ErrorModel','proportional');% Robust fit �kIII
%','Exclude',FitDataX>100  %�ư����W�L100���ȡC
a=mdl.Coefficients.Estimate;


slope=a(2);
intercept = log10(a(1));
p=[slope intercept];

rightBound=log10(1.1*max(FitDataX));
leftBound=log10(0.9*min(FitDataX));
ex = logspace(leftBound,rightBound,100); % �q10^leftBound��10^rightBound�����إ�100�ӫ��Ƶ����Z���V�q
yy = a(1)*ex.^a(2);%���X���

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

