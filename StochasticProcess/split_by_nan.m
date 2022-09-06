function [C_notnan, Cid_notnan] = split_by_nan(Y)
Y2 = Y(:); % to make sure Y is N by 1.
id_nan = isnan(Y2);
notNaN = ~id_nan;
sizeY_dim2 = size(Y,2);
id_nansplit = diff(id_nan); % indicates the midpoints that separate NaN and non-NaN elements.
lensplitpt = length(id_nansplit);

id_cross = false(lensplitpt, 1); % adjMultiply(Y2) < 0; % indicates the midpoints where Y(i)*Y(i - 1) are negative.
% ... that is, Y transits from positive to negative, or vice versa.
% id_bothOutside = adjAND(notNaN); % indicates the midpoints where both Y(i) and Y(i - 1) are not NaN.
% ... that is, Y(i) and Y(i - 1) are outside thr.
id_nonansplit = id_cross; % and(id_cross, id_bothOutside);
id_split = or(id_nansplit,id_nonansplit);
id_split_ext = [1;id_split;1];
edges = find(id_split_ext); % the edges/boundaries for segments.
id_nonansplit_ext = [0;id_nonansplit;0];
edges2 = sort([edges; find(id_nonansplit_ext)]);
durations = diff(edges2); % the duration/numel of each segment.
C = mat2cell(Y,durations(:),sizeY_dim2);
lenC = length(durations);

firstseg = C{1};
if isnan(Y2(1)) || isempty(firstseg) % all is faster than any
    % NaN and non-NaN segments should occur in turn.
    % Hence if firstseg is all nan, then 1:2:end indicates the inside_thr
    % segments.
    ind_notnans = 2:2:lenC;
    ind_nans = 1:2:lenC;
else % first segment is not nan or empty
    ind_notnans = 1:2:lenC;
    ind_nans = 2:2:lenC;
end

C_notnan = C(ind_notnans);

id1s = csum(durations);
id0s = [1;id1s(1:end - 1)+1];

Cid = arrayfun(@(id0, id1) id0:id1, id0s, id1s, 'UniformOutput',false);
Cid_notnan = Cid(ind_notnans);

return
Y_notnan_ind = julialikerange(id0s(ind_notnans),id1s(ind_notnans));
Y_nan_ind = julialikerange(id0s(ind_nans),id1s(ind_nans));

end