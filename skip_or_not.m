function [inputstruct] = skip_or_not(status_or_path,varargin)
%% How to use: (also see demo_skip_or_not.m)
%     status_saved = 'temp_c3.mat';
%     range_i = 1:14;
%     range_j = 2:8;
%     TO = skip_or_not(status_saved,range_i,range_j);
%     for i = range_i
%         for j = range_j
%             % put 'skip_or_not' at the very beginning of the inner-most loop to
%             % avoid other 'continue'.
%             
%             % before do anything
%             TO = skip_or_not(TO); if TO.continue; continue; end
%             % do something
%         end
%     end
%     TO = skip_or_not(TO,'finish'); % to make sure all iterations are finished.


%%
switch class(status_or_path)
    case 'struct'
        inputstruct = status_or_path;
        initializing = false;
%         if nargin>1 && strcmp(varargin{1},'finish')
%             inputstruct.last_count = inputstruct.last_count + 1;
%             save(inputstruct.filepath,'inputstruct');
%             return
%         end
    case {'char','string'}
        dispmsg = ["Previous status file for SOP_2019_Batch exists. ";...
            "Click left button to load (continue from) previous status.";...
                "Start a complete new session"];
        if validpath(status_or_path) && warninginput('Message',dispmsg,'LeftButtonText','Load previous',...
                'RightButtonText','Fresh start','CountDown',15)
            inputstruct = only1field(status_or_path);
            inputstruct = init_on_load(inputstruct);
            inputstruct.filepath = status_or_path; % update filepath
            disp('[skip_or_not] Preivously saved status loaded.');
        else
            inputstruct = struct();
            disp('[skip_or_not] New structure created.');
            if regexp(status_or_path,'\.mat','once')
                inputstruct.filepath = status_or_path;
            else
                inputstruct.filepath = 'continue_or_not_default.mat';
            end
            inputstruct = init_on_new(inputstruct);
        end
        
        initializing = true;
        
        
    otherwise
        error('1st argument has to be a structure or path of a matfile.')
end



%% on finish (MAKE SURE varargin is not used before this section)

if nargin > 1 && ischar(varargin{end})
    
    if strcmp(varargin{end},'finish')
        inputstruct.task_completed = true;
%         inputstruct.iter_skipped = unique(inputstruct.iter_skipped);
%         inputstruct.iter_not_skipped = unique(inputstruct.iter_not_skipped);       
        if inputstruct.total_iters == numel([inputstruct.iter_not_skipped,inputstruct.iter_skipped])
            save(inputstruct.filepath,'inputstruct');
            disp('Mission complete!')
        else
            % bad
            dispmsg = ["([skip_or_not]'finish')";...
                    "There might be unexpected 'continue' in the loop.";...
                    " Please Check.";"automatically ignored"];
            if warninginput('Message',dispmsg,'LeftButtonText','Raise an error',...
                'RightButtonText','Ignore this','CountDown',15)
                error('Aborted by user.');
            end
            
        end
        return
    else
        warnmsg = ["[skip_or_not] ",...
            sprintf("input argument '%s' is unsupported and will be ignored.",varargin{end}),...
            "To indicate the work session is completely done,  ",...
            "add 'finish' as the last input argument."];
        warning(strcat(warnmsg{:}))
    end
    varargin(end) = [];
end

if inputstruct.task_completed
    disp('task already completed. delete the file for status to restart.')
    inputstruct.continue = true; % do skip
    return
end

if initializing
    % initialization

    if isfield(inputstruct,'ranges') && ~isequal(inputstruct.ranges,varargin(:))
        dispmsg = ["inputstruct.ranges and varargin(:) are inconsistent.";...
                    "Start a new session"];
        if warninginput('Message',dispmsg,'LeftButtonText','Abort',...
            'RightButtonText','Do it now','CountDown',15)
            error('Aborted by user.');
        end
        inputstruct = init_on_new(inputstruct);
    end
    inputstruct.ranges = varargin(:); % must be a cell array

    inputstruct.total_levels = numel(inputstruct.ranges);
    inputstruct.counter = 0;
    
%     inputstruct.last_iter_index = zeros(1,inputstruct.total_levels);
    inputstruct.total_iters = prod(cellfun(@(x) numel(x),inputstruct.ranges));
    
%% (keep error raised before initializing)
else % inside_the_loop
%     current_iters = [varargin{:}]; % must be a numeric array
%     if numel(current_iters)~=numel(inputstruct.ranges)
%         error('incorrect usage. nargin must be the same outside and inside the for loop.');
%     end
    inputstruct.counter = inputstruct.counter + 1; % if no error, then counter +1

    if inputstruct.counter < inputstruct.last_count 
        inputstruct.continue = true; % do skip
        inputstruct.iter_skipped = [inputstruct.iter_skipped, inputstruct.counter];
%         return
        
    else % don't skip and update last_count.
        % inputstruct.last_count - 1 < inputstruct.counter  % then update last_count
        inputstruct.last_count = inputstruct.counter; % inputstruct.last_count + 1;
        inputstruct.continue = false; % do not skip
        inputstruct.iter_not_skipped = [inputstruct.iter_not_skipped, inputstruct.counter];
        save(inputstruct.filepath,'inputstruct');
    end
    
%     if inputstruct.last_count > inputstruct.total_iters
%         inputstruct.task_completed = true; 
%         % it is unnecessary if 'finish' is always correctly used.
%     end
%     save(inputstruct.filepath,'inputstruct');
end



end

function inputstruct = init_on_new(inputstruct)
    inputstruct.last_count = 0;
    inputstruct.task_completed = false;
    inputstruct.iter_not_skipped = [];
    inputstruct.iter_skipped = [];
end

function inputstruct = init_on_load(inputstruct)
    if ~inputstruct.task_completed
        inputstruct.iter_not_skipped = [];
        inputstruct.iter_skipped = [];
    end
end
