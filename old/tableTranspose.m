function [tableT] = tableTranspose(tableO)
% Reference 
% https://www.mathworks.com/matlabcentral/answers/395567-how-can-i-transpose-a-dataset-or-table
funcNm = 'tableTranspose';
tableORowNames = tableO.Properties.RowNames;
Xc = table2cell(tableO);
if isempty(tableORowNames)
    warning('[%s] Table do not have RowNames.',funcNm);
    rowNmCandidate = {'name','names'};
    Lia = ismember(rowNmCandidate,tableO.Properties.VariableNames);
    try
        if any(Lia)
            idx = find(Lia,1); % find only one element is enough.
            buildInName = rowNmCandidate{idx};
            warning("[%s] Use inputTable.%s to be the RowNames.",funcNm,buildInName);
            tableO.Properties.RowNames = tableO.(buildInName);% update table RowNames
    %         NoR =size(tableO,1);
    %         AutoRowName = cell(NoR,1);
    %         suffix = [1:NoR];
    %         AutoRowName(:) = {sprintf('Row_%d',suffix(:))};
        else
            error('Cannot find a variable containing names in the table.');
        end
    catch ME
        ME.message = sprintf('Failed when applying building names. (%s)',ME.message);
        error(ME);
    end
    
    
end
tableT = cell2table(Xc','RowNames',tableO.Properties.VariableNames,'VariableNames',tableO.Properties.RowNames);
end

