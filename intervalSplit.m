function [outputArg1] = intervalSplit(Arg1,splitters,varargin)
% Input: 
% Argument 1: an interval [t0,t1] or a series (1 by n array)
% Argument 2 to n: the splitting point
% Output:
% Argument 1: a N by 2 array indicating the [start,end] splitted intervals


% splitters(:) = varargin{:};
[splitters,lengthsplitters] = trans2vert(splitters); %make sure Arg1 is N by 1 array;

Arg1 = Arg1(:); %make sure Arg1 is N by 1 array; an faster way for trans2vert

NoR = lengthsplitters +1;


% switch class(Arg1)
%     case 'datetime'
%        outputArg1 = NaT(NoR,2);
%        diffArg1 = days(1);
%     case 'double'
%        outputArg1 = NaN(NoR,2);
%        diffArg1 = 1;
%     case 'logical'
%         
% end
outputArg1 = repmat(Arg1(1),NoR,2);
outputArg1(end,2) = Arg1(end);
outputArg1(2:end,1) = splitters;
outputArg1(1:end-1,2) = splitters;





end

