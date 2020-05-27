% Split sample path of SDE at the point where sign reversed, and remove tail.
% e.g. [Y_tail_removed, split_idx, segs, ordinal ,segments_sorted] = split_SDE(Y_i,'remove','le5');
% if no removement, Y_i(1:split_idx(end)) should be equal to Y_o.
% 
% INPUT: 
% % Y_i: sample path of SDE, DON'T remove signs.
% Parameter: 
% % 'remove','le5': remove segments of numel less equal than 5
% 
% OUTPUT: [Y_o(tail removed) ,split_index 
%                  varargout: [segments, ordinal_idx, segments_sorted]
% % split_index point at the end of each segment
function [Y_tail_removed,split_idx,varargout] = split_SDE(Y_i,varargin)
% option1 = {'leq*pt'};
% valid_op1 = @(x) any(validatestring(x,option1));

p = inputParser;
   %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); %addRequired(p,'thick',validScalarPosNum);
%    addRequired(p,'Y_i');
%    addOptional(p,'DF',{});
   addParameter(p,'remove',0);      
   parse(p,varargin{:});
   rus = p.Results;
   Y = Y_i(:); % to make sure Y is N by 1.
   %Y = rus.Y_i;  
   rm0 = rus.remove; 
   
   diff_sgnY = diff(sign(Y));
   split_idx = find(diff_sgnY); % index of non-zero element. the index of splitting. 
   
   
   
   nSegs = numel(split_idx);
   if nSegs<=1
       warning('No split at all. Make sure that the input timeseries CANNOT be sign-removed.');
   end
   segments = cell(nSegs,1);
   
   for i = 1:nSegs
       try
           a = split_idx(i-1)+1;
       catch ME
           if i==1
               a = 1;
           else
               rethrow(ME);
           end
       end
       b = split_idx(i);
       segments{i} = Y(a:b);
   end
   
if any(rm0~=0)
    S = regexp(rm0,'(?<name>\D*)(?<value>\d*)','names');
    for i = 1:numel(S)
        name = S(i).name;
        value = str2double(S(i).value);
        switch name
            case {'le','leq'}
                idx_delete = cellfun(@(x) le(numel(x),value), segments);
                segments(idx_delete)= [];
        end
    end
end
   
   
   Y_tail_removed = cell2mat(segments);
%    assignin('base','Y_o',Y_o);
%    assignin('base','Y_i',Y);
   
   if ~isequal(Y_tail_removed,Y(1:numel(Y_tail_removed)))
       warning('Notice that Y input/output are not consistent, some segments removed');
   else
%       if ~isequal(Y_i(1:split_idx(end)),Y_o)
%            warning('something wrong');
%        else
%            disp('good')
%        end

   end
   
%    fprintf('nargout is: %d',nargout);
   if nargout>2 % varargout is 1 or more
       [segments_sorted, ordinal_idx] = sort_by_numel(segments);
       varargout{1} = segments;
       
       if nargout > 3
           varargout{2} = ordinal_idx;
       end
       
       if nargout > 4 % 5 varargout
           varargout{3} = segments_sorted;
       end
   end
end

function [cell_array_sorted, ordinal_idx] = sort_by_numel(Nx1_cell_array)
numel_in_cell = cellfun(@(x) numel(x), Nx1_cell_array);
[numel_sorted , ordinal_idx] = sort(numel_in_cell);
cell_array_sorted = Nx1_cell_array(ordinal_idx);
end

