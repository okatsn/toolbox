function [varargout] = only1field(varargin)
% This function remove the most outer unnecessary structure if the input structure has only one field(substructure).
% input: a path or a structure.
%    input path: [loadedStructure1,loadedStructure2,...] = only1field(path1,path2,...);
%    input structure: [structure1,structure2,...,structureN] = only1field(structure1,structure2,...,structureN);
% e.g. structureN have to be a one by one structure with only one substructure (which is superfluous), or an error will raise.
% e.g. [S_output] = only1field(S_input); % BEFORE: S_input.S.field1; AFTER: S_output.field1; 
%
% e.g  S =  load('PredParam.mat'); PredParam = S.Param; % is equvalent to
%         PredParam = only1field('PredParam.mat');
%

% nargin = numel(varargin);
varargout = cell(1,nargin);
for i = 1:nargout
    inputArg1 = varargin{i};
    class_input = class(inputArg1);
    switch class_input
        case 'struct'
            [outputArg2,fieldname]=ifisstruct(inputArg1);
        case {'char','string'}
            if validpath(inputArg1)
                AA = load(inputArg1);
                [outputArg2,fieldname]=ifisstruct(AA);

            else
                warning('Input %d may not be a valid windows path. Return nothing.',i)
                outputArg2 = struct();
            end
        case 'cell'
            if length(inputArg1)>1
                warning( 'Input variable %d contains multiple cells. Return only the first one',i);
            end
            outputArg2 = inputArg1{1};
    end
    varargout{i} = outputArg2;
end
% if nargout>1
%     varargout{1} = fieldname;
% end

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

