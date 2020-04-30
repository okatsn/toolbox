%% array contain numeric
A = [1 3 4 5 7 9]; % target list
B = [1 8 3 7];           % member list
ismember(A, B) % Return logical array indicates is element in A one of the member of B.
% ans =  1กั6 logical array  [ 1   1   0   0   1   0 ]

%% cell contain string
A = {'pig','dog','cat'};
B = strfind(A,'cat'); disp(B)
Index = find(not(cellfun('isempty',B))); disp(Index) %Index = [3]
target = A(Index); % is a 1*1 cell {'cat'}
target_c = A{Index};  % is a string 'cat'
disp(target);  disp(target_c);

% cell contain string (new)
Index_n = find(contains(A,{'ca','do'})); %Index_n = [2 3]
target_n = A(Index_n); % is a cell {'dog','cat'}
target_n_c = A{Index_n};  % is string 'dog'

