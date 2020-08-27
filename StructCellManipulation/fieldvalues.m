function [fieldValues] = fieldvalues(S,varargin)
% Return a cell array of the corresponding values of a structure 
% according to fieldNames
% (that probably come from fieldNames = fieldnames(S)).
% How to use:
%     fieldvalues(S)
%         which is equivalent to 
%     fieldvalues(S,fieldnames(S))

if nargin> 1
    fieldNames = varargin{1};
else
    fieldNames = fieldnames(S);
end
fieldValues = cellfun(@(x) S.(x), fieldNames,'UniformOutput',false);
end

