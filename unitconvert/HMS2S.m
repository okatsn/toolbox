function [total_seconds] = HMS2S(datevec)
% Convert N by 3, [hours, Minutes, seconds] to seconds.
numRows = size(datevec,1);
total_seconds = datevec(:,end-2:end).*repmat([3600,60,1],numRows,1);
total_seconds = sum(total_seconds,2);
end

