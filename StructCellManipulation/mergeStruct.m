function [structure2] = mergeStruct(structure1)
% merge structure (numel(S)>1) in which there are all with empty fields except one. 
% usually deal with the S = regexp(input,expr,'names');
if numel(structure1)==1
    warning('no need to merge. return nothing.')
    structure2 = structure1;
    return
end

fNms = fieldnames(structure1);
% only return the field names of 1st level. 
structure2 = struct();

for i = 1:length(fNms)
    Nm = fNms{i};
    structure2.(Nm) = [structure1.(Nm)];
end



end

