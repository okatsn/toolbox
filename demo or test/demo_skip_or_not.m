status_saved = 'temp5555553.mat';
range_i = 1:4;
range_j = 2:8;
TO = skip_or_not(status_saved,range_i,range_j);
counts = 0;
other_continue = true;
for i = range_i

    for j = range_j
        % put 'skip_or_not' at the very beginning of the inner-most loop to
        % avoid other 'continue'.
        counts = counts +1;
%         if other_continue && counts == 3
%             continue % if there's 'continue' before 'skip_or_not', things will goes wrong.
%         end
        TO = skip_or_not(TO);
        
        if TO.continue
            fprintf('(%d) skipped\n',counts);
            continue
        else
            
            fprintf('(%d) do\n',counts);
        end
        a = 1+1;        % do something
%         if counts == 18 
%             error('error that may occurred in the script.') 
%         end % comment this in the second try

    end
end
TO = skip_or_not(TO,'finish'); % to make sure all iterations are finished.

%%
status_saved = 'temp5555553.mat';
range_i = 1:14;
range_j = 2:8;
TO = skip_or_not(status_saved,range_i,range_j);
for i = range_i
    for j = range_j
        % put 'skip_or_not' at the very beginning of the inner-most loop to
        % avoid other 'continue'.

        % before do anything
        TO = skip_or_not(TO); if TO.continue; continue; end
        % do something
    end
end
TO = skip_or_not(TO,'finish'); % to make sure all iterations are finished.