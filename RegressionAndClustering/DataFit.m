% To do list:
% % check again if all fit functions are ok
% e.g.
% input_M = abs(Y_pre);   [CCDF,umax2,u] = calc_CCDF(input_M); Y=CCDF; X=u;     
% DF1 = DataFit(X,Y,'TEX(CCDF)','umax',umax2);
% DF2 = DataFit(X,Y,'EXP(CCDF)','umax',umax2);
% figure;
% DataFitPlot(X,Y,{DF1,DF2},'YScale','log','Title',title_name_2); 

function [ DF ] = DataFit(X,Y,fit_to,varargin)
% expectedFit = {'TEX_CCDF','TEX(CCDF)','EXP','EXP(CCDF)','erf_CCDF',...
%     'erf(CCDF)','wet_CCDF','b-value','G-R law','loglog'};
% valid_ft = @(x) any(validatestring(x,expectedFit));

   p = inputParser;
   %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
   addRequired(p,'X');
   addRequired(p,'Y');
   addRequired(p,'fit_to');
   addParameter(p,'umax',0);
   addParameter(p,'ReturnFunction',0);
   parse(p,X,Y,fit_to,varargin{:});
   rslt = p.Results;
   X = rslt.X; 
   Y = rslt.Y; 
   Return_And_Exit = rslt.ReturnFunction;
   fit_to = rslt.fit_to; 
   umax = rslt.umax;
%    assignin('base','rslt',rslt); %將變數(mnc2)傳到base workspace 作為 mnc2)
%    assignin('base','umax2',umax); %將變數(mnc2)傳到base workspace 作為 mnc2)

errorS = struct();


   
%'StartPoint' 只在方法是 'NonlinearLeastSquares' 可以設定
switch fit_to
    case {'TEX_CCDF','TEX(CCDF)'} % fit to CCDF of TEX

        if umax ==0
           errorS.message = 'Warning, parameter umax is required in this fitting function.';
           error(errorS);
        end

        options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1],'Lower',0 );
        FitFunction=@(ucft,t)  (exp(-t/ucft)-exp(-umax/ucft))/(1-exp(-umax/ucft) ); 
        % verified the same as FitDataA (12/18).
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});
%         DF.PDF=@(t) (t/ucft).*(exp(-t/ucft)/(1-exp(-umax/ucft)));  %TEX
%         DF.uavg2=integral(DF.PDF,0,umax); % 根據最佳擬合參數作圖(不放在這裡，需要的話另開function)
    case 'EXP' % fit to CCDF(?) of TEX
        options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1],'Lower',0 );
        FitFunction=@(ucft,t)  (1/ucft)*(exp(-t/ucft))  ; %%  
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});
        
    case {'EXP(CCDF)'}
        options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1],'Lower',0 );
        FitFunction = @(ucft,t)  (exp(-t/ucft));
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});

        
    case {'erf_CCDF','erf(CCDF)'}
        options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1],'Lower',0 );
        FitFunction = @(ucft,t)  1-erf(0.5*sqrt(2)*sqrt(1/ucft)*t)/erf(0.5*sqrt(2)*sqrt(1/ucft)*umax); 
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});
        %    CCDF(?) of NORMAL PDF
        
    case {'b-value','G-R law'}
        options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1,1],'Lower',0 );
        
        FitFunction = @(a,b,t) 10.^(a-b*(2/3)*log10(t)-6.07);
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});
    case {'loglogfit'}
        error('use loglogfit instead');
        logX = log10(X);
        logY = log10(Y);
        %p = polyfit(x,y,n)%p為x的n次多項式前的係數，降冪排列
        [p, ~] = polyfit(logX,logY,1);%logY=p(1)*logX+p(2)
        slope=p(1);
        intercept = p(2);
    case {'omegasquare'}
        M_flat
        
        M_f = M_flat/sqrt(1+(f/fL)^2)/sqrt(1+(f/fH)^2); % M as a function of frequency f
    case {'linear'}
        options = fitoptions('Method','LinearLeastSquares'); % ,'StartPoint', [0,0]

        FitFunction = @(a,b,t) a+b*t;
        FitFunctionType=fittype( FitFunction ,'independent',{'t'});
    case {'Now_working(old DataFit3)'}
% FitDataX=ipt2.dataT;
% FitDataY=ipt2.absDataY;
% 
% FitFunctionType=fittype({'x','1'},'coefficients',{'m','b'} );%Model of %%%%%%%%%%%%%       Linear fit a*x+b*1
% 
% [DF3.fitt1,DF3.gof,output] = fit(FitDataX.',FitDataY.',FitFunctionType);
% c1=coeffvalues(DF3.fitt1);
% DF3.c1=c1;
% 
% FitDataY=ipt2.dataY2;%
% FitFunctionType=fittype({'x','1'},'coefficients',{'m','b'} );%Model of %%%%%%%%%%%%%       Linear fit a*x+b*1
% [DF3.fitt2,DF3.gof,output] = fit(FitDataX.',FitDataY.',FitFunctionType);
% c2=coeffvalues(DF3.fitt2);
% DF3.c2=c2;
        
    otherwise
        error("The value of 'fit_to' is invalid.");
        
end

DF.FitFunction = FitFunction;
if ~isequal(Return_And_Exit,0)
    warning('(DataFit) Did not fit. Return function handle only.');
    return
end

[DF.fitt,DF.gof,DF.output] = fit(X,Y,FitFunctionType,options);
ucft=coeffvalues(DF.fitt);
DF.best_fit_coeff = ucft;
DF.fit_to = fit_to;

end

