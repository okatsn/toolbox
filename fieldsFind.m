function [var_in_cell_1,fieldNames1] = fieldsFind(input_structure,regexpr)
% input a structure and a keyword, return the cell of fields whose name
% containing keyword. e.g. [var_in_cell_1,fieldNames1]  = fieldsFind(input_structure,regexpr)
% fieldnames and struct2cell return the field names and the values in the same order.
% colNm ='Athr';

switch class(input_structure)
    case 'struct'
        var_in_cell_1 = struct2cell(input_structure);
        fieldNms0 = fieldnames(input_structure);
        idx = cellfun(@(x) any(regexp(x,regexpr)),fieldNms0);
        var_in_cell_1 = var_in_cell_1(idx)';
        fieldNames1 = fieldNms0(idx)';
% doubleS1 = cell2mat(cellS1);
    case 'table'
%         input_structure = tsAIN;
        fieldNms0 = input_structure.Properties.VariableNames;
%         idx_to_delete = cellfun(@(x) ~any(regexp(x,regexpr)),fieldNms0);
        idx = cellfun(@(x) any(regexp(x,regexpr)),fieldNms0);
%         input_structure(:,idx_to_delete) = [];
        var_in_cell_1 = table2cell(input_structure(:,idx));
        fieldNames1 = fieldNms0(idx);
end


end

