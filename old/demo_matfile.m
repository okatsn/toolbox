% demo_matfile

%% https://www.mathworks.com/matlabcentral/answers/457291-how-can-i-append-the-same-variables-on-mat-file
% use this
s = size(m, 'my_variables');
m.my_variables(s+1, :) = new_row_of_values;

%avoid this
m.my_variables(end+1, :) = new_row_of_values;    
% as apparently using "end" forces the entire variable to be loaded into memory.