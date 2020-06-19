function [O] = get_all_tags(inputstring,varargin)
% Similar to get_tags
% inputchar = '[XXXX]_trn[20190510].matXXXX_frc[20190808].mat';
% Example 1:
%     O = get_all_tags(inputstring);
%     tags_trn = O.trn;
%     tags_frc = O.frc;
%     tags_other = O.tag_1;
% Example 2:
%     expr = '(?<=thr\[).+?(?=\])';
%     O = get_all_tags(inputstring,expr);

if nargin>1
    expr = varargin{1};
else
    expr = '(?<=\[).+?(?=\])';
end
all_values = regexp(inputstring,expr,'match');
inputstring2 = regexprep(inputstring,all_values,''); % delete tags from inputstring.
% e.g. make '_trn[2019]' to '_trn[]', to make the following regexp easier.

all_names = regexp(inputstring2,'\w*?\[(?=\])','match'); % e.g. match '_trn[' or '['
all_names = regexprep(all_names,'(_|\[)',''); % delete '[' or '_'
empty_id = cellfun(@isempty,all_names); % check if empty after delete '['
num_empty = sum(empty_id);
no_name_tags = cellfun(@(x)sprintf('tag_%d',x),num2cell(1:num_empty),'UniformOutput',false);
% if empty, give a name such as 'tag_1' for the no-name tag.
all_names(empty_id) = no_name_tags;

name_val_pairs = reshape([all_names;all_values],1,[]);
O = struct(name_val_pairs{:});

end

