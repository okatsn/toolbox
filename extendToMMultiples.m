function [array1d] = extendToMMultiples(array1d,M,varargin)
% extend the 1-d array to length N that is the multiple of M, and hence
% it can be correctly reshaped to M by R or R by M.
%     How to use:
%         extendToMMultiples(array1d,M);
%         extendToMMultiples(array1d,M,'ones'); % default is 'NaN'

ab = size(array1d);
[minsize,minid] = min(ab);
if minsize~=1
    error('input array has to be 1-dimensional');
end
maxsize = length(array1d);
Remaining = rem(maxsize,M);
if Remaining ~= 0
    numel2append = M - Remaining;
else
    return
end


if minid == 1 % array 1d is 1 by N 
    array2append = NaN(1,numel2append);
    array1d = cat(2,array1d,array2append); % append_dir = 2;
else % 2, array 1d is N by 1
    array2append = NaN(numel2append,1);
    array1d = cat(1,array1d,array2append); % append_dir = 1;
end


end

