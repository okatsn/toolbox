function [largest_dimension] = largestDim(A)
% return the largest dimension of an array/matrix

sizeA = size(A);
[~,largest_dimension] = max(sizeA);

end

