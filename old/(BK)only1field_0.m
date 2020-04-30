function [outputArg2,varargout] = only1field(inputArg1)
% This function remove the most outer unnecessary structure if the input structure has only one field(substructure).
% e.g. BEFORE: S_input.S.field1; AFTER: S_output.field1;
% e.g  S =  load('PredParam.mat'); PredParam = S.Param; % is equvalent to
%         PredParam = only1field('PredParam.mat');
% input: a path or a structure.
%    input path: [loadedStructure] = only1field(path);
%    input structure: [structure1x1] = only1field(structure1x1);
% e.g. structure1x1 have 
class_input = class(inputArg1);
switch class_input
    case 'struct'
        [outputArg2,fieldname]=ifisstruct(inputArg1);
        
    case {'char','string'}
        if validpath(inputArg1)
            AA = load(inputArg1);
            [outputArg2,fieldname]=ifisstruct(AA);

        else
            warning('This may not be a valid windows path. Return nothing.')
            outputArg2 = struct();
        end
        
end

if nargout>1
    varargout{1} = fieldname;
end

end

function [outputArg2,fieldname]=ifisstruct(inputArg1)
errorStruct.identifier = 'Custom:Error';
fNms = fieldnames(inputArg1);
if numel(fNms) ==1
    outputArg2 = inputArg1.(fNms{1});
    fieldname = fNms{1};
else
    errorStruct.message = 'Input structure have multiple fields. It is dangerous to assign fields to varargout.';
    error(errorStruct);           
end

end

