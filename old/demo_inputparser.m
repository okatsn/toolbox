%% DEMO 2018.12.18
expectedFit = {'TEX','EXP','erf','wet'};
valid_ft = @(x) any(validatestring(x,expectedFit));
expectedDo = {'JointStation','GEMSTIP','erf','wet'};
validDo = @(x) all(ismember(x,expectedDo));
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
valid10 = @(x) (x==1) || (x==0);

p = inputParser;
addRequired(p,'X');
addRequired(p,'Y');
addRequired(p,'fit_to',valid_ft);
% Warning, function must have varargin if addParameter is used. 
addParameter(p,'umax',0,validScalarPosNum);      
% varargin{:} must be parsed otherwise parameter will always remains default value.
parse(p,X,Y,fit_to,varargin{:});  
rslt = p.Results;
X = rslt.X; Y = rslt.Y; fit_to = rslt.fit_to; umax = rslt.umax;


%%
clear all
    p = inputParser;
    check1 = @isnumeric;
    check2 = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    addRequired(p,'num',check1) %or check 2, it's ok to have no check, such as addRequired(p,'num');

    parse(p,2) %parse(p,'text') will fail since check1('text') is false.
    p.Results.num


function TF = check2(x) % an equivalent function for check 2
   TF = false;
   if ~isscalar(x)
       error('Input is not scalar');
   elseif ~isnumeric(x)
       error('Input is not numeric');
   elseif (x <= 0)
       error('Input must be > 0');
   else
       TF = true;
   end
end
    
clear all
   defaultHeight = 1;
   defaultUnits = 'inches';
   defaultShape = 'rectangle';
   expectedShapes = {'square','rectangle','parallelogram'};
   
   width =1;
   thick = 2;
   varargin1={'height',9,'shape','parallelogram','pig','yes'};
   %varargin1={h,unit,shap};
   
   p = inputParser;
   validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
   addRequired(p,'width',validScalarPosNum);
   addRequired(p,'thick',validScalarPosNum);
   addOptional(p,'height',defaultHeight,validScalarPosNum);
   addOptional(p,'pig',0);
   addOptional(p,'cat','default_cat_name',@isstring); 
   %Require 和 Optional 是按照順序input ，例如 parse(p,width,2,9,4,"mix")
   addParameter(p,'units',defaultUnits,@isstring);      
   %Parameter則必須是 Name-value pair arguments 輸入。
   addParameter(p,'shape',defaultShape,@(x) any(validatestring(x,expectedShapes)));
   %parse(p,width,2,varargin1{:});
   parse(p,width,2,9,4,'shape','square'); %parse(p,width,2,9,4,"mix")
   % output: thick=2; height = 9; pig = 4; (as the default of required/optional input variables)
   
   rslt = p.Results;

% 傳統設預設值的方法
% if ~exist('D','var'), D = 5.34; end
% if ~exist('r','var'), r = 1; end
% if ~exist('totalTime','var'), totalTime = 10; end
% if ~exist('T','var'), T = struct; end
% if ~exist('Y0','var'), Y0 = 0; end
% if ~exist('dt','var'), dt = 1e-5; end
% switch nargin
%     case nDefault
%         Y0=0; dt=1e-5;%default value
%     case nDefault+1
%         Y0 = varargin{1};%起點
%     case nDefault+2
%         Y0 = varargin{1};%起點
%         dt = varargin{2};%時間步數區間
%     otherwise
%         error('%d default and maximun 5 inputs expected',nDefault)
% end

% 小技巧
%   if nargin > nDefault && any(strcmp(varargin,'plotSomething'))
%      figure;plot(x);
%   end

