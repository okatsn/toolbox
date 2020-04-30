function [Arg1,varargout] = trans2vert(Arg1)
% input: a m by n array
% output:
% 1. the same as Arg1 but with number of rows the length of Arg1 (the 'vertical' one)
% 2. length of Arg1
% 3. size of Arg1
% 
% For 1 by n array, consider using Arg1 = Arg1(:); it is 10 times faster
% for both case (no matter the original one is vertical or not).

SzArg1 = size(Arg1); % SzArg1 = [NoR1,NoC1];
[lengthArg1,idxmax] = max(SzArg1);

% you may also use A = A(:) will output N by 1 array

% if idxmax ==1 % NoR1 is larger, need not to convert.
if idxmax ==2%, that is length(Arg1) = NoC1 
    Arg1 = Arg1'; % convert to n by 1 array;
end
if nargout>1
    varargout{1} =  lengthArg1;
    if nargout >2
        varargout{2} = SzArg1;
    end
    
end

end

