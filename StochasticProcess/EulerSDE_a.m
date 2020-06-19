% Produce a SDE sample path by numerically solving the Langevin equation in Euler scheme.
% Example: 
%     O = EulerSDE_a(D,r,totalTime,Y0,dt, 'FrictionType','wet','PlotTrace',1);
%     O = EulerSDE_a(D,r,totalTime,Y0,dt,'FrictionType','dry','smooth','1000pt','RemoveSign',1);
% INPUT:
%     Required: 
%         D: diffusional coefficient
%     Optional:
%         r: frictional/damping coefficient
%         totalTime: duration of the process (length of the sample path)
%         Y0: initial condition
%         dt: \Delta t (smaller, more accurate)
%     Parameter:
%         FritionalType: Type of Langevin equation
%         PlotTrace: 1 for plot, 0 not plot.
%         seed: use pre-saved seed.
%         save_to: 
%             save_to =1: save to default folder; 
%             Alternatively: save_to = 'subfolder1\subsubfolder'; 
%         smooth:  
%             e.g. smooth = '100pt'; % smooth to total 100 points.
%             e.g. smooth = '0.1sec'; % averaging window is 0.1 second.
%         MemoryLimit: (2020-06-04)
%             Manually assign the largest number of elements of the array at a time.
%             In default the function will automatically decide the number 
%             by estimating the available memory of the device at current state.
%             However, if you use parfor to run this function, the number should
%             be divided by the number of parfor iterations; otherwise, 
%             memory might runs out. That is, you should manually set 'MemoryLimit' 
%             when the function is executed inside the parfor loop.
%
% Becareful when change the variable name 'traceT';
%
% About rng seed:
% e.g. 
% % seed = rng; 
% % rng(seed); 
% % A1 = cat(2,randn(1,4),randn(1,5)); 
% % rng(seed); 
% % A2 = cat(2,randn(1,3),randn(1,3),randn(1,3)); 
% % isequal(A1,A2);
% % % then you will find out that A1 is completely the same as A2
        
% drift term & diffusional term are calculated in the same line. 
% Therefore, it's 2 times faster than EulerSDE_b, but unable to see the
% influence of drift term in microscale.  
function [ O ] = EulerSDE_a(D,varargin )% EulerSDE_a(D,r,totalTime,Y0,dt)
default_r = 1; default_totalTime = 10; default_Y0 = 0; default_dt = 1e-3;  default_Friction = 'dry';

errorStruct.identifier = 'Custom:Error';
default_VH = 0; %default_outputdW=0; 
expected_types = {'dry','wet','viscous', 'Coulomb'};
valid_types = @(x) any(validatestring(x,expected_types));
default_plot = 0;   
validScalar = @(x) isnumeric(x) && isscalar(x); % if vector or string, then error. %this term is optional.
valid10 = @(x) (x==1) || (x==0);
p = inputParser;
addRequired(p,'D',validScalar); % note that there shouldn't exist a default term here. 
%============ below default value is required.
addOptional(p,'r',default_r); 
addOptional(p,'totalTime',default_totalTime,validScalar); %validScalar is optional
addOptional(p,'Y0',default_Y0,validScalar);
addOptional(p,'dt',default_dt);
addParameter(p,'FrictionType',default_Friction,valid_types); %e.g. 'FrictionType','dry' ( Name-value pair arguments input)
addParameter(p,'plot',default_plot,valid10); %e.g. 'PlotTrace', 1 ( Name-value pair arguments input)
% addParameter(p,'OutputdW',default_outputdW); %e.g. 'OutputdW', 1 ( Name-value pair arguments input)
% addParameter(p,'VelocityHistory',default_VH); %e.g. 'VelocityHistory', 1 ( Name-value pair arguments input)
addParameter(p,'seed',NaN); 
addParameter(p,'save_to',0); 
addParameter(p,'smooth',0);
addParameter(p,'RemoveSign',0);
addParameter(p,'information',0);
addParameter(p,'SaveInplace',0); 
addParameter(p,'ConstantForce',0);
addParameter(p,'TimeElapse',false);
addParameter(p,'MemoryLimit',0);


% addParameter(p,'SteadyStateMean',0); % comparing with the theoretical averaged value in stationary state.
% 'SteadyStateMean',0.3 will average the last 30% of Y as steady state average.

% addParameter(p,'function','');
%============ above default value is required.
parse(p,D,varargin{:});
results = p.Results;
r=results.r; totalTime = results.totalTime; Y0 =results.Y0; dt = results.dt; save_to=results.save_to;
FrictionType = results.FrictionType; 
smooth = results.smooth; 
Plot_= results.plot;
absFcn = results.RemoveSign;
showInfo = results.information;
SaveInplace = results.SaveInplace;
TimeElapseTR = results.TimeElapse;
constantForce = results.ConstantForce;
Fcxdt = constantForce*dt;
% SteadyStateMean = results.SteadyStateMean;
% function_ = results.function;
% FrictionType = results.FrictionType; 
memoryLimit = results.MemoryLimit;

if isequal(memoryLimit,0)
    % estimate appropriate array size to be load a time according to memory.
    memoryLimit = limitnumel('double')*0.85;
else
    memoryLimit = round(memoryLimit); % to avoid error.
end


Save2 = false;
t = 0; y=Y0; % must precede t = matf.traceT(end);
if ~isequal(SaveInplace,0)
    if smooth~=0
        warning("'SaveInplace' is assigned, 'smooth' has been reset to zero.")
        smooth=0;
    end
    totalTime_j = min([totalTime,round(memoryLimit*dt,-2)]);
    iter_j = ceil(totalTime/totalTime_j);
    fprintf('OutputDuration/totalTime = %.2f/%.2f \n',totalTime_j*iter_j,totalTime)
    Save2 = true;   
       
    if isfile(SaveInplace) % if file exist
%         FileExist = true;
        fprintf("File exists. Append to '%s' \n",SaveInplace);
        matf = matfile(SaveInplace,'Writable',true);
        size_T = size(matf,'X');
        endidx = size_T(1);
        t = matf.X(endidx,1); %don't use 'end', for example matf.traceT(end) will force load variable into memory
        y = matf.Y(endidx,1);
    else % create new matfile
%         FileExist = false;
        X = [];
        Y = [];
        StartPoint = [];
        varNames = {'D','r','dt','FrictionType','StartPoint','X','Y'};
        save(SaveInplace,varNames{:},'-v7.3');               
        matf = matfile(SaveInplace,'Writable',true);
        fprintf("Create new file to '%s' \n",SaveInplace);
        size_T = [0,0];
    end
    
    
%     if isfield(matf,'StartPoint') % isfield cannot work with fields of matfile
        matf.StartPoint =  [matf.StartPoint, max(size_T) +1]; % previous [StartPoint, EndPoint +1];
%     else
%         matf.StartPoint =  [NaN, max(size_T) +1]; % 
%     end

    
end



if smooth~=0
%     smth_to = regexp(smooth,'(pt|sec)','match');
%     smooth_parameter = regexp(smooth,'\d+\.?\d*e?[+-]?\d*\.?\d*(?=(pt|sec))','match');
% '\d+\.?\d*': 數字(至少1) 小數點(1或0次) 數字(0至無限位) 
% 'e?[+-]?\d*\.?\d*': 字母e(1或0次) (字符集)[+或-](1或0次) 數字(0至無限次) 小數點(1或0次) 數字(0至無限位) 
% '(?=(pt|sec))': 後面要接著pt或sec才會匹配到
     Sm = regexp(smooth,'(?<sp_>\d*\.?\d*e?[+-]?\d+\.?\d*)(?<st_>pt|sec)','names');
     smooth_parameter = Sm.sp_;
     smth_to = Sm.st_;
     smooth_parameter = str2double(smooth_parameter);
     smooth = 1;% this significantly speed up when smooth_parameter is large.
%     
%     assignin('base','smooth_parameter',smooth_parameter);
    switch smth_to
        case 'pt' % smooth to total m point
            m = smooth_parameter;
            tmp = totalTime/m/dt;
            steps=round(tmp); %Euler method跑n步(共N+1筆資料，第一筆為初始條件)
            Nw=steps+1;% points in each window
%             assignin('base','Nw',Nw); % DEBUG
%             assignin('base','m',m); % DEBUG
            T_smth = NaN(m,1); Y_smth = NaN(m,1);
            smooth_info = sprintf('smooth to %d %s',smooth_parameter,smth_to);
        case 'sec' % smooth window (in seconds) = smooth_parameter
            tmp = totalTime/smooth_parameter;
            m = round(tmp); % total m point
            steps=round(smooth_parameter/dt); %Euler method跑n步(共N+1筆資料，第一筆為初始條件)
            Nw=steps+1; % points in each window
            T_smth = NaN(m,1); Y_smth = NaN(m,1);
            smooth_info = sprintf('smooth window = %d %s',smooth_parameter,smth_to);
    end
    
else % not smooth
    if Save2
        m = iter_j;
        steps=round(totalTime_j/dt); 
    else
        m = 1;
        steps=round(totalTime/dt); 
    end
    Nw=steps+1;%Euler method跑n步(共n+1筆資料，第一筆為初始條件)
    
    smooth_info = 'original';
end



% permission = 'yes';
if or(Nw>memoryLimit,m>memoryLimit)
%     permission = input('Large array warning, may run out of memory. Continue anyway ? [yes/no]','s');
    warning('(You should not see this) Large array warning, memory may run out. Be careful to the status of memory usage');
    pause(5);
end

sigma=sqrt(dt);  % variance=sigma^2
mm=0;%mean of dW
if isstruct(results.seed)
   rng(results.seed); %if structure then use the input seed (e.g. 'seed',O.seed)
   O.seed = results.seed;
else
   O.seed=rng;%儲存隨機變數的種子，以便需要時能重現。
end


%% Time series generation

switch FrictionType
    case {'wet','viscous'}
        drift = @(x) -r*x;
        Y_avg_predicted = sqrt(2*D/(pi*r));
    case {'dry','Coulomb'}
        drift = @(x) -r*sign(x);
        Y_avg_predicted = D/r;
    case {'mixture','general'}
        if numel(r) ==2
            r1 = r(1);
            r2 = r(2);
            drift = @(x) -r1*x-r2*sign(x);
        else
            errorStruct.message = 'if friction type is mixture, r have to be 1 by 2 double, the 1st one is viscous; 2nd one is for dry. For example, r = [1,3]';
            error(errorStruct)
        end
end
% dWm = cell(m,1); % for debug use.
b=sqrt(2*D);

if TimeElapseTR
    tic; H = timeLeft0(m,'EulerSDEa');
end

% if isequal(SaveInplace,0)
for k=1:m
    dW=sigma.*randn(1,steps)+mm;%平均值為零%一次產生n個隨機變數(1列n行)。Nw=steps+1;
%     dWm{k} = dW; % for debug use.
    traceT=NaN(Nw,1); traceY=NaN(Nw,1);
    traceT(1)=t;    traceY(1)=y;%initial condition
        for i=2:Nw
            t=t+dt;   
            y=y+drift(y)*dt+b*dW(i-1) + Fcxdt;           
            traceT(i)=t;  
            traceY(i)=y; %
        end

    if absFcn~=0
        traceY = abs(traceY);
    end

    if Save2
%         if k==1
%             if ~FileExist
%                 save(SaveInplace,'traceT','traceY','-v7.3');               
%                 matf = matfile(SaveInplace,'Writable',true);
%             end
%         else
            size_Tk = size(matf,'X');
            next_idx0 = size_Tk(1) +1;
            next_idx1 = size_Tk(1) + Nw;
            matf.X(next_idx0:next_idx1,1) = traceT;
            matf.Y(next_idx0:next_idx1,1) = traceY;
            
            
%         end
        if TimeElapseTR
            [H] = timeLeft1(toc,k,H);
        end
    end

    if smooth~=0
        T_smth(k)=mean(traceT);
        Y_smth(k)=mean(traceY);
    end




end
if TimeElapseTR
    delete(H.waitbarHandle);
end
% else
%     dW=sigma.*randn(1,steps)+mm;%平均值為零%一次產生n個隨機變數(1列n行)。Nw=steps+1;
%     traceT=NaN(1,Nw); traceY=NaN(1,Nw);
%     traceT(1)=t;    traceY(1)=y;
%         for i=2:Nw
%         t=t+dt;   y=y+drift(y)*dt+b*dW(i-1);           traceT(i)=t;  traceY(i)=y; %
%         end
% 
%     segY{NoThr_i} = 1;
% 
%     
% end

%% Output
% assignin('base','dWm',dWm);
O.D = D; O.r = r;


%% if smoothed
  %if nargin > nDefault && any(strcmp(varargin,ftn1))
if smooth==0
    O.X = traceT;
    O.Y = traceY;
else
  O.X = T_smth;
  O.Y = Y_smth;% All output time series transpose to size = [N,1]
  
end

if showInfo~=0
    O.std_Y = std(O.Y);
    O.mean_Y = mean(O.Y);
    O.varianceOfdW=var(dW);%應該要等於dt
    O.meanOfdW=mean(dW);
    O.steps=Nw*m-1;
    O.Gamma = (b/dt)*dW; % output fluctuating force Gamma(t)
    O.elementsInTrace=numel(O.X);
end
O.smth_tag = smooth_info;
O.mean_Y_predicted = Y_avg_predicted;

% if ~isequal(SteadyStateMean,0)    
%     O.mean_Y_avg_samplepath_st = 
% end

%% Figure plot

  if Plot_ == 1
      f1= figure;
      midFont=15;
      subplot(2,1,1);
      plot(O.X,O.Y,'.');
      xlabel('time','FontSize',midFont);       ylabel('Y(t)','FontSize',midFont);
      ax=gca; ax.YGrid='on';
      subplot(2,1,2);
      plot(O.X,abs(O.Y),'.')
      xlabel('time','FontSize',midFont);       ylabel('|Y(t)|','FontSize',midFont);
      ax=gca;  ax.YGrid='on';
  
        pos_x=0; superTitle =sprintf('D=%.2f; \\gamma=%.2f; frictionType: %s',D,r,FrictionType);
        other.FontSize = 18;  %← 設定這裡
        pos_y=0.91;  pos = [pos_x pos_y 1-pos_x 1-pos_y] ; %[x_start y_start width height] of textbox.
        other.HorizontalAlignment = 'center'; other.VerticalAlignment = 'bottom';
        annote(superTitle,pos,f1,other);
  
        if isstruct(results.seed)
            info1 ='seed: previously saved';
        else
            if isnan(results.seed)
            info1 ='seed: newly generated';
            end
        end

        info2 = sprintf('smoothed to %s',smooth_info);
        other_info = {info1,info2}; % can be {info1; info2;...} ';' is for break line.
        other2.VerticalAlignment = 'bottom';
        annote(other_info,[0 0.02 1 0.1],f1,other2);  
  
  figure;
  histogram(dW); title('distribution of dW');
  
  figure;
  std_Y = std(O.Y);
  histogram(O.Y); title('distribution of Y');
  x0 = std_Y;  label1 = {'+1std','-1std','+2std','-2std','+3std','-3std'};
  x1 = {x0,  -x0  ,2*x0  ,-2*x0  ,+3*x0,  -3*x0};
  ylim_ = get(gca,'ylim');
  vline(x1,ylim_,label1);

  
  end
  
 %% save variable
  if save_to == 1
      save_to = ''; % save to current path.
  end
  if ~isequal(save_to,0)
     fn = fullfile(pwd,save_to);
        if exist(fn, 'dir')
           fprintf('save to %s',save_to);
         else
            warning('folder "%s" not exist. Created one.',save_to);
            mkdir(fn);
        end
        fname = sprintf('D=%.2f-r=%.2f-T=%d-Type=%s.mat',D,r,totalTime,FrictionType);
        target_dir = fullfile(fn,fname);
%         save(target_dir,'O','-v7.3');% for variable larger than 2GB
        save(target_dir,'O');
  end
    
  
end
%% annotation
function annote(text,pos,fig,other)
dim = pos;  
a=annotation(fig,'textbox',dim,'String','');
%建立annotation時必定要先設定contanier(可以是方形、橢圓、箭頭)的大小和他的對應文字
a.String = text;
a.LineStyle='none';%設定沒有外框

    if isfield(other,'HorizontalAlignment') % 'left' (default) | 'center' | 'right'
        %Alignment 是指 文字對齊於textbox的'左'、'中'或'右'側
       a.HorizontalAlignment = other.HorizontalAlignment;
    end
    
    if isfield(other,'VerticalAlignment') % 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
       a.VerticalAlignment = other.VerticalAlignment;
    end
    
    if isfield(other,'FontSize')
       a.FontSize = other.FontSize;
    end

end

function vline(x,ylim_,label_)
hold on 

for i = 1:numel(x)
line([x{i},x{i}],ylim_,'Color','g');
text(x{i},ylim_(2),label_{i},'Color','g','VerticalAlignment','top');
end

end


