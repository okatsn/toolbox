function [nearest_idx_1,value_1] = nearestBelow(array1,near_to)
% find the element in array1 which is nearest AND BELOW (or equal) to 'near_to'.
% 1st output: the index of the nearest element in array1.
% 2nd output: the value of the nearest element in array1.

[array2,I] = sort(array1);
% array2 = array1(I);

nearest_idx_2 = find(array2<=near_to,1,'last');
nearest_idx_1 = I(nearest_idx_2);

if nargout>1
    value_1 =  array1(nearest_idx_1);
end
end

