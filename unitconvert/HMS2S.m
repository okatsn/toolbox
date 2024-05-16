% `[total_seconds] = HMS2S(datevec)` converts a matrix N by 6 `datevec` to
% a N by 1 array of double, being the values in the unit of second.
% The six columns of `datevec` should be in the order of year, month, day, hour, minute and second.
function [total_seconds] = HMS2S(datevec)
% Convert N by 3, [hours, Minutes, seconds] to seconds.
numRows = size(datevec,1);
total_seconds = datevec(:,end-2:end).*repmat([3600,60,1],numRows,1);
total_seconds = sum(total_seconds,2);
end

