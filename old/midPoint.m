function [vector_out_N_by_1] = midPoint(vector_in)
v1 = vector_in(:); % make sure it is N by 1 array.
v2 = v1;
v1(end) = [];
v2(1) = [];
v3 = [v1,v2];
vector_out_N_by_1 = mean(v3,2);


end

