function [ varout1,varargin1 ] = demo_arginout_(  )
 % varargin is a 1-by-N cell array
 % nargout = 1:  op1 = somefunc();
 % nargout = 2:  [op1,op2] = somefunc(); 以此類推
 [X,Y,Z]= func1(1,2,3,'a','b');
disp(sprintf('func1: X = %d;  Y= %d;  Z= %d',X,Y,Z)); %#ok<*DSPS>

[a,b,c,d,e] = func2();
disp(sprintf('func2:  a=%d;  b=%d;  c=%d;  d=%d;  e=%d;',a,b,c,d,e));

[a,b,c,d] = func3('A','B','C','D');
disp(sprintf('func3:  a=%s;  b=%s;  c=%s;  d=%s;;',a,b,c,d));

varargin1 = {'A','B','C','D'};
[varout1] = func3(varargin1);
disp(sprintf('func3:  a=%s;  b=%s;  c=%s;  d=%s;;',varout1{1},varout1{2},varout1{3},varout1{4}));

A = regexp('top2%','(abs|top)|%','match');
[varout1,varout2,varout3,varout4] = func3('A','B','C',A);
    assignin('base','varout4',varout4); %將變數(mnc2)傳到base workspace 作為 mnc2
    % 註：function workspace ('caller'); Matlab workspace ('base')
end




 function [X,Y,Z]=func1(X,Y,varargin)
 disp(sprintf('func1 :nargin = %d',nargin));
 disp(sprintf('func1 :number of varargin = %d',numel(varargin)));
 if nargin > 2
     Z = varargin{1};
 end
 end
 
 function [a,b,varargout] = func2()
 % nargin會等於 2 + numel(varargin)
 a=1;b=2;
     for k = 1:nargout-2 %1到output數量。例如[x1,y1] = somefunc(X,Y,'z')則nargout=2
        varargout{k} = k;
     end
     disp(sprintf('func2 :number of varargout = %d',numel(varargout)));
     disp(sprintf('func2 :number of nargout = %d',nargout));
 end
     
 function varargout = func3(varargin)
     for i =1 : nargin %number of argument. 例如somefunc(X,Y,'z')則nargin = 3, 
         varargout{i} = varargin{i};
     end
 end

 
 % varargin 範例 https://www.mathworks.com/help/matlab/ref/varargin.html
 function varargout = redplot(varargin)
    [varargout{1:nargout}] = plot(varargin{:},'Color',[1,0,0]);
end