function array2sum = csum(array2sum)
% this function add elements of inputnumarray one-by-one, and return an
% cumulatively summed array of the same size.
% e.g. 
%     inputnumarray = [1,3,2,4];
%     cumulative_added_array will hence be [1,4,6,10]

numelarray = numel(array2sum);

% cumulative_added_array = NaN(size(inputnumarray));
% inputarray1d = inputnumarray(:);
for i = 2:numelarray
    array2sum(i) = array2sum(i) + array2sum(i-1);
end

end