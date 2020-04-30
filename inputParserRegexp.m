function [Results,function_varargin] = inputParserRegexp(function_varargin,NameOnly_cell,varargin)
%  [Results,function_varargin] = inputParser2(function_varargin,NameOnly_cell,OptionalNameDefaultvaluePair_cell)
% inputParser2 assign true/false to names exist in function_varargin, and
% assign values to names just as addParameter. After that, name and
% name-values pair will be all deleted from function_varargin
%     NameOnly_cell should be names that is designed to have no value pair.
%     function_varargin should be the varargin of the parent function.
%     varargin{1} is optional NameValuePair_cell
Results = struct();
errorStruct.identifier = 'Custom:Error';
%% Single name
if nargin>1 % then  find, assign true, and delete non-name-value paired options. (MUST BE DONE FIRST)
    LoV = length(NameOnly_cell); 
    LoFv = length(function_varargin);
    idx2del = false(1,LoFv);
    
    for i = 1:LoV
%         try
%             SetSthIdx = cellfun(@(x) strcmpi(x,NameOnly_cell{i}),function_varargin);%,'UniformOutput',false);
            
            for j = 1:LoFv
                
                expr = sprintf('(?<name>%s)(?<value>\\d*\\.?\\d*e?[+-]?\\d+\\.?\\d*)?',NameOnly_cell{i});
                varargin_j = function_varargin{j};
                
                if ~ischar(varargin_j)
                    continue
                end
                
                
                  S = regexp(varargin_j,expr,'names');
                  if isempty(S)
                    Results.(NameOnly_cell{i}) = false;
                      continue
                  end

%                 if any(SetSthIdx)
                    Results.(NameOnly_cell{i}) = str2double(S.value);
                    idx2del(j) = true;
                    
%                 else
%                     Results.(NameOnly_cell{i}) = false;
%                 end
            end

    end
    function_varargin(idx2del) = [];
end
%% Name-value pair.
% if ~isempty(function_varargin)
    if nargin>2
        NameValuePair_cell = varargin{1};
        LoNV = length(NameValuePair_cell);
        if mod(LoNV,2) ~= 0 % if number of elements are not even 
            errorStruct.message = 'Name-value not paired. May due to the typo of parameter input';
            error(errorStruct)
        end    
        
        
    %     ismember(NameValuePair_cell,function_varargin); % ismember works for
    %     only when members of two sets are all char or all double
        for i = 1:2:LoNV
            SetSthIdx = cellfun(@(x) strcmpi(x,NameValuePair_cell{i}),function_varargin);%,'UniformOutput',false);
            if any(SetSthIdx) % then assign
                targetIDX = find(SetSthIdx,2,'first');
                Results.(NameValuePair_cell{i}) = function_varargin{targetIDX+1};    
                function_varargin(targetIDX:targetIDX+1) = [];
            else % then default
                Results.(NameValuePair_cell{i}) = NameValuePair_cell{i+1};    
%                 Results.(NmOfNameValuePair_cell{i}) = false;
            end
        end
        
        
    else

%         NmOfNameValuePair_cell = function_varargin(1:2:end);
%         inputkeys = function_varargin(1:2:end);
%         inputvals = function_varargin(2:2:end) ;
%         for i = 1:length(inputkeys)
%             Results.(inputkeys{i}) = inputvals{i};
%         end
    end
  


% end
end

