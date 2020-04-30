function [status] = which_for(status_or_path,varargin)%range_i,range_j,range_k,range_l,varargin)
error('This function is deprecated. Use skip_or_not.m instead.');

% this function have to be put right after 'for' in the for loop.

% example:


% status_saved = 'temp.mat';
% 
% range_i = 1:5;
% range_j = 2:8;
% status = which_for(status_saved,'ranges_full',{range_i,range_j});
% % continue from the previous incomplete iteration. If there is no file can
% % be loaded, completely go through range_i and range_j.
% 
% for i = range_i
%     for j = range_j
%         % put 'which_for' at the very beginning of the inner-most loop
%         status = which_for(status,'CurrentIteration',[i,j],'Save',status_saved);
%         if status.continue; continue; end
%         % do something
%     end
% end
% which_for(status,'last');

validpath_x = @(x) validpath(x) || regexp(x,'\.mat','once');
validate_rng = @(x) isnumeric(x) || iscell(x);
p = inputParser;
fullranges_nm = 'ranges_full';
current_iter_nm = 'CurrentIteration';
addParameter(p,'Save',0,validpath_x);
% addParameter(p,'Load',0,validpath_x);
addParameter(p,fullranges_nm,{},validate_rng);
addParameter(p,current_iter_nm,[],isnumeric);
isnumeric(2);
% addParameter(p,'MissionComplete',false);
parse(p,varargin{:});
r = p.Results;
save_mat_to = r.Save;
assignedfullranges = r.(fullranges_nm);
current_iter = r.(current_iter_nm);

if ~iscell(assignedfullranges)
    assignedfullranges = {assignedfullranges};
end

switch class(status_or_path)
    case 'struct'
        inputstruct = status_or_path;
        inputstruct.outside_the_loop = false;
    case {'char','string'}
        if validpath(status_or_path)
            inputstruct = only1field(status_or_path);
        else
            inputstruct = struct();
            inputstruct.skipfollowing = false;
            disp('new structure created.');
        end
        inputstruct.outside_the_loop = true;
    otherwise
        error('1st argument has to be a structure or path of a matfile.')
end

if inputstruct.skipfollowing
    return;
end

fullrngassigned = ~isempty(assignedfullranges);
fullrngfieldexists = isfield(inputstruct,fullranges_nm);

%% assign the field of for-loop range (full)
if ~fullrngassigned && ~fullrngfieldexists % must assign fullrange outside the loop
    error("'%s' must be assigned.",fullranges_nm);
% elseif ~fullrngassigned && fullrngfieldexists
%     % do nothing
elseif fullrngassigned && fullrngfieldexists % wrong use of this function
    msg = strcat("'%s' is not equal to 'status.%s'. ",...
        "A new session will be started using '%s' ",...
        "(previous saved status will be ignored)");
    msg2 = compose(msg,fullranges_nm,fullranges_nm,fullranges_nm);
    warning(msg2);
    if warninginput('Message',msg2,'FontSize',10,...
            'LeftButtonText','Abort (return True)','RightButton','Continue (return False)')
        error('Aborted by user.');
    end
    inputstruct.(fullranges_nm) = assignedfullranges;
elseif fullrngassigned && ~fullrngfieldexists % outside the loop
    inputstruct.(fullranges_nm) = assignedfullranges;
end

numel_nestedlevel = numel(inputstruct.(fullranges_nm));
iterNm = compose('current_iter_%d',[1:numel_nestedlevel]);

if numel_nestedlevel~=numel(current_iter)
    str0 = strcat("numel(%s) must equal numel(%s), but it is not. ",...
    "Hence the inputstruct.skipfollowing is set to be true, ",...
    "and the 'which_for' function in the following iteration will be skipped ",...
    "to avoid errors.");
    str1 = compose(str0,fullranges_nm,current_iter_nm);
    warning(str1);
    inputstruct.skipfollowing = true; % this should be unnecessary if the script is good enough.
    return
end


all_true_to_continue = false(1,numel_nestedlevel);

for i = 1:numel_nestedlevel
    inputstruct.(iterNm{i}) = current_iter(i);
    if
        all_true_to_continue(i) = true;
    end
end
    



% if isequal(assignedfullranges,0) % if no assignment to 'ranges_full', then load it from the inputstruct.
%     if ~inputstructexist
%         error("If there is no inputstruct, 'ranges_full' must be assigned.");
%     else % inputstruct exists
%     assignedfullranges = inputstruct.ranges_full;
%     end
% else % 'ranges_full' are assigned
%     if inputstructexist 
%         if ~isequal(inputstruct.ranges_full,assignedfullranges) % but confilcts with status.ranges_full
%             warning...
%         end
%     end
% end



if isfile(status_saved) % continue from previous interrupted point
    previous_status = only1field(status_saved);
    for i = 1:numel()
        range_i = previous_status.range_1; 
    end
else

end

status.Complete = false;
% if current_i == range_i(end)
%     status.Complete = true;
% else
%     status.Complete = false;
%     [Lia,current_idx] = ismember(current_i,range_i);
%     status.range_incomplete = range_i(current_idx:end);
%     status.range_completed = range_i(1:current_idx-1);
% end

if numel(range_i) ~= numel(unique(range_i))
    warning(['There are duplicated indices in the range_i of the for loop. ',...
        'the output status might incorrectly reflect the true progress.'])
end
if ~isequal(save_mat_to,0)
    if isfolder(save_mat_to)
        save_mat_to = [save_mat_to, filesep, 'status_temp.mat'];
    end
    status.destination = save_mat_to;
    save(save_mat_to,'status');
end
    
end

