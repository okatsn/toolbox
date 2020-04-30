function [Results,function_varargin2] = inputParser2(function_varargin,NameOnly_cell,varargin)
%  [Results,function_varargin] = inputParser2(function_varargin,NameOnly_cell,OptionalNameDefaultvaluePair_cell)
% inputParser2 assign true/false to names exist in function_varargin, and
% assign values to names just as addParameter. After that, name and
% name-values pair will be all deleted from function_varargin
%     NameOnly_cell should be names that is designed to have no value pair.
%     function_varargin should be the varargin of the parent function.
%     varargin{1} is optional NameValuePair_cell
Results = struct();
errorStruct.identifier = 'Custom:Error';
    if nargin>2
        errorStruct.message = 'Name-value pair is deprecated. Use inputParser; addParameter(); after  [Results,varargin] = inputParser2 instead.';
        error(errorStruct);
    end

    
noncharidx = cellfun(@(x) ~ischar(x),function_varargin);
function_varargin2 = function_varargin;
function_varargin2_restore = function_varargin2(noncharidx);
function_varargin2(noncharidx) = {'tmp'};
NameValue_Name = find(noncharidx) - 1; % the one before non-char one is not belong to NameOnly_cell and should not be deleted.
%% Single name
if nargin>1 % then  find, assign true, and delete non-name-value paired options. (MUST BE DONE FIRST)
    LoV = length(NameOnly_cell); 
    for i = 1:LoV
%          try
            SetSthIdx = cellfun(@(x) strcmpi(x,NameOnly_cell{i}),function_varargin2);%,'UniformOutput',false);
            
%             
%          catch ME
%              switch ME.identifier
%                  case 'MATLAB:cellfun:NotAScalarOutput'
%                      warning('varargin{%d} ignored',i);
%                      
%                  otherwise
%                      errorStruct.message = 'Check the inputs. Change inputParser2(func_var,Names) to inputParser2(func_var,Names{:}) may solve the problem ';
%                      error(errorStruct)
%              end
%          end
        if any(SetSthIdx)
            Results.(NameOnly_cell{i}) = true;
            if ismember(SetSthIdx,NameValue_Name)
                errorStruct.message = 'A name of name-value pair conflicts with the one in name-only input.';
                error(errorStruct);% the one before non-char one should not be deleted.
            end
            
            function_varargin2(SetSthIdx) = [];
        else
            Results.(NameOnly_cell{i}) = false;
        end
    end
end
%% Name-value pair. 
% Deprecated, use 
% p = inputParser; addParameter(); after  [Results,varargin] = inputParser2


% if ~isempty(function_varargin)
%     if nargin>2
%         NameValuePair_cell = varargin{1};
%         LoNV = length(NameValuePair_cell);
%         if mod(LoNV,2) ~= 0 % if number of elements are not even 
%             errorStruct.message = 'Name-value not paired. May due to the typo of parameter input';
%             error(errorStruct)
%         end    
%         
%         
%     %     ismember(NameValuePair_cell,function_varargin); % ismember works for
%     %     only when members of two sets are all char or all double
%         for i = 1:2:LoNV
%             SetSthIdx = cellfun(@(x) strcmpi(x,NameValuePair_cell{i}),function_varargin);%,'UniformOutput',false);
%             if any(SetSthIdx) % then assign
%                 targetIDX = find(SetSthIdx,2,'first');
%                 Results.(NameValuePair_cell{i}) = function_varargin{targetIDX+1};    
%                 function_varargin(targetIDX:targetIDX+1) = [];
%             else % then default
%                 Results.(NameValuePair_cell{i}) = NameValuePair_cell{i+1};    
% %                 Results.(NmOfNameValuePair_cell{i}) = false;
%             end
%         end
%         
%         
%     else
% 
% %         NmOfNameValuePair_cell = function_varargin(1:2:end);
% %         inputkeys = function_varargin(1:2:end);
% %         inputvals = function_varargin(2:2:end) ;
% %         for i = 1:length(inputkeys)
% %             Results.(inputkeys{i}) = inputvals{i};
% %         end
%     end
  


% end
end

