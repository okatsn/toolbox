function [vector_out_N_by_1] = logMidPoint(vector_in)
% vector_in: a 1d array with N+1 elements
% vector_out: a N by 1 array being the midpoints of every two adjacent
% elements of vector_in

v1 = log(vector_in(:)); % make sure it is N by 1 array.
v2 = v1;
v1(end) = [];
v2(1) = [];
vector_out_N_by_1 = exp((v1+v2)*0.5);

end

