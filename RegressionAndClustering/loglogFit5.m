function [ O ] = loglogFit5( X,Y )
%�Hlogfit.m���ť��A²�ƪ���loglog�M��fit

% make this compatible with skipping some points.... don't know how yet....
%range=[min(X) max(Y)];
%        logRange=log10(range);
%        totRange=diff(logRange)+10*eps; % in case its all zeros...
%        logRange = [logRange(1)-totRange/20, logRange(2)+totRange/20];
%        ex = linspace(logRange(1),logRange(2),100); % note this is in log10 space

logX=log10(X);
logY=log10(Y);
%p = polyfit(x,y,n)%p��x��n���h�����e���Y�ơA�����ƦC
[p, ~] = polyfit(logX,logY,1);%logY=p(1)*logX+p(2)
slope=p(1);
intercept = p(2);

rightBound=1.1*max(logX);
ex = linspace(0,rightBound,100); % note this is in log10 space
        
yy = polyval(p,ex);%yy=�Hp���Y�ƪ�x��n���h�����Fx�Hex�ȱa�J�Ayy�����������

%case 'loglog'
        yy=10.^yy;
        ex=10.^ex;

        estY=polyval(p,logX); % the estimate of the 'y' value for each point.
        estY=10.^estY; logY=10.^logY;% need to do this for error estimation              
        MSE = mean((logY-estY).^2); % mean squared error.
        
O.MSE=MSE;
O.rmse=sqrt(MSE);
O.slope=slope;
O.intercept=intercept;
O.PolyCoeff=p;

%Plot the data
plot(X,Y,'o');
% Plot the approximate line
hold('on'); % in case hold off was on before
plot(ex,yy,'.');

end

