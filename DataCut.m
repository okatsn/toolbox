function [indPreserved,varargout] = DataCut(refarrayorfieldname,Range,varargin)
% Cut on inputObj according to reference array. Cut in direction 1 (i.e. vertical).

% expectedStructure = {'tsAIN'};
% valid_struc = @(x) any(validatestring(x,expectedStructure));
% 
% p = inputParser;
% addParameter(p,'Structure',0,valid_struc);
% parse(p,varargin{:});
% structinput = p.Results.Structure;
% 
% if isequal(structinput,0)
%    switch structinput
%        case 'tsAIN'
%            
%        case ''
%        
%    end
% end

if nargin>2
    inputObj = varargin{1};
else
    inputObj = refarrayorfieldname;
end

if isstring(Range) % if range is string then convert it to datetime.
    Range = datetime(Range,'InputFormat','yyyyMMdd');
end

minRng = min(Range);
maxRng = max(Range);
% type_inputtable = class(inputObj);
typeref = class(refarrayorfieldname);
switch typeref
    case {'string','char'}
        array1 = inputObj.(refarrayorfieldname);
    otherwise % double, datetime array.
        array1 = refarrayorfieldname;
end

[NoRTb] = size(inputObj,1);
SzDt = length(array1);

if SzDt~=NoRTb
   warning('[DataCut] Number of rows of inputObj is not identical with sortbyarray.');
end

idx4rm = array1 < minRng | array1 > maxRng;
indPreserved = ~idx4rm;


if nargout>1
    outputobj = inputObj(indPreserved,:);   
    varargout{1} = outputobj; 
end

end

