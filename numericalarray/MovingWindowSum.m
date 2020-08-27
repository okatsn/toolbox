function [summation,idx4t] = MovingWindowSum(aseries,windowlength)
% Summation in a moving window, indexed at the last element of the moving
% window. [summation,idx4t] = MovingWindowSum(aseries,windowlength)
% [summation] = MovingWindowSum(aseries,windowlength) 
% t(idx4t) will be the corresponding time to summation, indexed at the last element.


inputSz = size(aseries(windowlength:end));
if min(inputSz)~=1
    errorStruct.identifier = 'Custom:Error';
    errorStruct.message = 'input time series must be a 1 by N or N by 1 array.';
    error(errorStruct) 
end


summation = zeros(inputSz);



for i = 1:max(inputSz)
    summation(i) = sum(aseries(i:i+windowlength-1));  
end

if nargout ==2
    idx4t = true(size(aseries));
    idx4t(1:windowlength-1) = false;
end

end

