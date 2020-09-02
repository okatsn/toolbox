function [nearest_idx_1,value_1] = nearestBelow(array1,near_to)
% find the element in array1 which is nearest AND BELOW (or equal) to 'near_to'.
% 1st output: 
%     the index of the nearest element in array1.
% 2nd output: 
%     the value of the nearest element in array1. (must be 1d)
% 
% Efficiency:
%     if near_to has elements less than 4, nearestBelow is slightly faster than
%     nearest1d. For a large amount of elements in near_to, nearestBelow is 
%     slower. But if the amonts of near_to is very large, nearest1d will fail
%     due to run out of memory.

% array1 = array1(:);
% near_to = near_to(:);
% near_to_ext = repmat(near_to,length(array1),1);



[array2,I] = sort(array1); 
len_near_to = length(near_to); 
nearest_idx2 = NaN(len_near_to,1);
for i = 1:len_near_to
  nearest_idx2(i) = find(array2<=near_to(i),1,'last');
end

% array2 = array1(I);
nearest_idx_1 = I(nearest_idx2);

if nargout>1
    value_1 =  array1(nearest_idx_1);
end
end

