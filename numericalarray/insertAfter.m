function [to_this] = insertAfter(vals, right_after, to_this)
% insert values (vals) right after the indices (right_after) of the array (to_this).

ArraySz = size(to_this);

if min(ArraySz) ~= 1
    error('input has to be an array of 1 dimension');
end

if length(right_after) ~= length(vals)
    error('The number of indicies must equal to that of the values to insert.');
end

if isequal(ArraySz,[1,1]) 
    catdir = 2;% to prevent error of cat(1,x(1:1),'to_insert',x(2:end))
    %  cat(2,x(1:1),'to_insert',x(2:end)) is okay.
else
    [length_array,catdir]  = max(ArraySz);
end

k = 0;

for i = right_after
    n = i + k;
    k = k + 1;
    to_this = cat(catdir,  to_this(1:n), vals(k), to_this(n+1:end));
    % if to_this has 10 elements, to_this(11:end) will be empty, so it's
    % safe that n + 1 may exceed the largest dimension.
    
end

end

