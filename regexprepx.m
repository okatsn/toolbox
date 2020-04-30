function [inputchar] = regexprepx(inputchar,match_patterns,replaced_by)

if size(match_patterns) ~= size(replaced_by)
    error('size of match_patterns must be the same as the size of replaced_by');
end

if ~iscell(match_patterns) || ~iscell(replaced_by)
    error('Type of match_patterns and replaced_by must be cell containing characters.');
end


for i = 1:length(match_patterns)
    inputchar = regexprep(inputchar,match_patterns{i},replaced_by{i});
end
end

