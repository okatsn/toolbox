function [ O ] = EulerSDE_b(D,varargin )% EulerSDE_b(D,r,maxTime,Y0,dt)
% e.g. O = EulerSDE_b(D,r,T,Y0,dt,'FrictionType','wet','PlotTrace',1);
%Example: varargin = {2, 10, 0, 1e-6, 'FrictionType','wet','PlotTrace',1}
%D=diffusionCoefficient; r=frictionCoefficient

% �� EulerSDE_a �h���\��G
% Drift term and diffusional term are worked independently.
% �b�P�@dt���A�����O �M �H���O �����q��X�A�i�ݨ�L�[���t�׾��v �y�����t���ܤơA
% Output as O.traceT2 �H��  O.traceY2�C
% 
% ���O�A�@���N���A~2X slower than EulerSDE_a


default_r = 1; default_maxTime = 10; default_Y0 = 0; default_dt = 1e-5;  default_Friction = 'dry';
default_plot = 0;   expected_Friction = {'dry','wet'}; 
validScalar = @(x) isnumeric(x) && isscalar(x); % if vector or string, then error. %this term is optional.
p = inputParser;
addRequired(p,'D',validScalar); % note that there shouldn't exist a default term here. 
%============ below default value is required.
addOptional(p,'r',default_r,validScalar); 
addOptional(p,'maxTime',default_maxTime,validScalar); %validScalar is optional
addOptional(p,'Y0',default_Y0,validScalar);
addOptional(p,'dt',default_dt);
addParameter(p,'FrictionType',default_Friction); %e.g. 'FrictionType','dry' ( Name-value pair arguments input)
addParameter(p,'PlotTrace',default_plot); %e.g. 'PlotTrace', 1 ( Name-value pair arguments input)
addParameter(p,'seed',NaN); % example: 'seed',O.seed1
%============ above default value is required.
parse(p,D,varargin{:});
results = p.Results;
r=results.r; maxTime = results.maxTime; Y0 =results.Y0; dt = results.dt;
% FrictionType = results.FrictionType; PlotTrace= results.PlotTrace;

steps=round(maxTime/dt); %Euler method�]n�B(�@N+1����ơA�Ĥ@������l����)
Nw=steps+1;%Euler method�]n�B(�@n+1����ơA�Ĥ@������l����)
b=sqrt(2*D);

permission = 'yes';
if Nw>5e7
    permission = input('Large array warning, may run out of memory. Continue anyway ? [yes/no]','s');
end
if ~strcmp(permission,'yes') % if not 'yes'
    error('Execution aborted, for avoiding running out of the memory.')
end


sigma=sqrt(dt);  % variance=sigma^2
mm=0;%mean of dW
if isstruct(results.seed)
   rng(results.seed); %if structure then use the input seed (e.g. 'seed',O.seed1)
   O.seed1 = results.seed;
else
   O.seed1=rng;%�x�s�H���ܼƪ��ؤl�A�H�K�ݭn�ɯ୫�{�C
end
dW=sigma.*randn(1,steps)+mm;%�����Ȭ��s%�@������n���H���ܼ�(1�CN��)�C
O.varianceOfdW=var(dW);%���ӭn����dt
O.meanOfdW=mean(dW);


traceT2=NaN(1,2*Nw); traceY2=NaN(1,2*Nw);
t=0;   y=Y0;    traceT2(1)=t;    traceY2(1)=Y0; traceT2(2)=t;    traceY2(2)=Y0;
    
        if  strcmp(results.FrictionType,'wet') %string compare
          for i=2:Nw
          t=t+dt;   traceT2(2*i)=t;  traceT2(2*i-1)=t;      
          y = y - r*y*dt;                 traceY2(2*i-1)=y; %WET
          y = y + b*dW(i-1);             traceY2(2*i)=y; %WET
%                    if traceY2(2*i)*traceY2(2*(i-1))<0 %�N��q����t�αq�t�쥿�C
%                    break
%                    end
          end
        else
            if strcmp(results.FrictionType,'dry') %string compare
          for i=2:Nw
          t=t+dt;    traceT2(2*i)=t;  traceT2(2*i-1)=t;     
          y = y -r*sign(y)*dt;        traceY2(2*i-1)=y; %dry
          y = y + b*dW(i-1);             traceY2(2*i)=y; %dry
          
%                    if traceY2(2*i)*traceY2(2*(i-1))<0 %�N��q����t�αq�t�쥿�C
%                    break
%                    end
          
          end
            end
        end
    



  O.traceT2=traceT2;
  O.traceY2=traceY2;
  O.traceT = traceT2(2:2:end);
  O.traceY = traceY2(2:2:end);
  O.elementsInTrace=numel(traceT2)/2;
  O.steps=Nw-1;
  O.Gamma = (b/dt)*dW; % output fluctuating force Gamma(t)
  O.dW = dW; % output fluctuating force Gamma(t)
%   if default_outputdW ==1
%   O.dW=dW;
%   end

  %if nargin > nDefault && any(strcmp(varargin,ftn1))
  if results.PlotTrace == 1

      f1= figure;
      midFont=15;
      subplot(2,1,1);
      plot(O.traceT,O.traceY,'.');
      xlabel('time','FontSize',midFont);       ylabel('Y(t)','FontSize',midFont);
      ax=gca; ax.YGrid='on';
      subplot(2,1,2);
      plot(O.traceT,abs(O.traceY),'.')
      xlabel('time','FontSize',midFont);       ylabel('|Y(t)|','FontSize',midFont);
      ax=gca;  ax.YGrid='on';
  
        pos_x=0; superTitle =sprintf('D=%.2f; r=%.2f; frictionType: %s',D,r,results.FrictionType);
        other.FontSize = 18;  %�� �]�w�o��
        pos_y=0.91;  pos = [pos_x pos_y 1-pos_x 1-pos_y] ; %[x_start y_start width height] of textbox.
        other.HorizontalAlignment = 'center'; other.VerticalAlignment = 'bottom';
        annote(superTitle,pos,f1,other);
  
        if isstruct(results.seed)
            text ='seed: previously saved';
        else
            if isnan(results.seed)
            text ='seed: newly generated';
            end
        end
        other2.VerticalAlignment = 'bottom';
        annote(text,[0 0.02 1 0.1],f1,other2);  
  
  figure;
  histogram(dW); title('distribution of dW');
  end
  

  
end

function annote(text,pos,fig,other)
dim = pos;  
a=annotation(fig,'textbox',dim,'String','');
%�إ�annotation�ɥ��w�n���]�wcontanier(�i�H�O��ΡB���B�b�Y)���j�p�M�L��������r
a.String = text;
a.LineStyle='none';%�]�w�S���~��

    if isfield(other,'HorizontalAlignment') % 'left' (default) | 'center' | 'right'
        %Alignment �O�� ��r�����textbox��'��'�B'��'��'�k'��
       a.HorizontalAlignment = other.HorizontalAlignment;
    end
    
    if isfield(other,'VerticalAlignment') % 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
       a.VerticalAlignment = other.VerticalAlignment;
    end
    
    if isfield(other,'FontSize')
       a.FontSize = other.FontSize;
    end

end


