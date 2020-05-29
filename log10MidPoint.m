function [vector_out_N_by_1] = log10MidPoint(vector_in)
% vector_in: a 1d array with N+1 elements
% vector_out: a N by 1 array being the midpoints of every two adjacent
% elements of vector_in
warning('log10MidPoint seems to give exactly the same output as logMidPoint');
warning('Consider abandon log10MidPoint if you prove the above statement to be true.');
v1 = log10(vector_in(:)); % make sure it is N by 1 array.
v2 = v1;
v1(end) = [];
v2(1) = [];
vector_out_N_by_1 = 10.^((v1+v2)*0.5);

end

