function [C1] = num2str2cell(numarray)
% convert numerical array to cell where each value is converted to string.
C0 = num2cell(numarray);
C1 = cellfun(@num2str,C0,'UniformOutput',false);
end

