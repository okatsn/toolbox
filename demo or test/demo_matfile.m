% demo_matfile

%% https://www.mathworks.com/matlabcentral/answers/457291-how-can-i-append-the-same-variables-on-mat-file
% use this
s = size(m, 'my_variables');
m.my_variables(s+1, :) = new_row_of_values;

%avoid this
m.my_variables(end+1, :) = new_row_of_values;    
% as apparently using "end" forces the entire variable to be loaded into memory.


%% Create/Save/Load
filepath = 'temp.mat';
if isfile(filepath) % if file already exist
    matObj = matfile(filepath,'Writable',true); % if file exist, default 'Writable' is false
else % create a new matfile with varnames as the field/variable names
    save(filepath,varnames{:},'-v7.3');               
    matObj = matfile(filepath,'Writable',true);
    % this is identical to matObj = matfile(filepath), that creates a new
    % writable matfile object and save if any variable is assigned (e.g. matObj.X = 1:10;).

end



