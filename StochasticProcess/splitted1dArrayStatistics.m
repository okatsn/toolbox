function [S] = splitted1dArrayStatistics(matfile1,varargin)
% How to use:
%     mtf = matfile('a_matfile_store_timeseries_Y.mat');
%     S = splitted1dArrayStatistics(mtf); % field name 'Y' must exist.
% - Calculate statistics of every segments from Time series stored in matfile.
% - The timeseries (t,v)  is read from matfile in batches for memory reason.
% - A segment is defined as the interval between two nearest adjacent points 
%     where the process (v) falls below the given 'Threshold'.
% 
% The stochastic process might not end (falls below the given 'Threshold') in one batch;
% the unfinished segment in one batch is called "a piece" of this kind of large segment a time.
% Because it is not possible to concatenate pieces into a segment larger than maximum memory,
% this function will sum up statistic values (e.g. duration) calculated from
% the pieces of one large segment that cross over several batches, 
% and eventually provides a statistics value for this large segment. 
% 
% Name-Value parameters:
% -  Validation
%     - 'CheckLong'
%         - plot the first segment in this batch, 
%           if the last segment of the previous batch is incomplete. 
%         - noted that 'CheckLong' only shows the first 6 plots.
%         - noted that 'CheckLong' indeed do not provide any validation;
%           it only provides visualizations that the user needs to check by eyes.
%     - 'CheckJump'
%         - check if there are discontinuities in the concatenated time series, 
%            by checking if there are gaps that is almost impossible to occurred in the stochastic process.
%         - If there is, there might be something wrong in EulerSDE_a.
%     - 'CheckNaN'
%         - Check if statistics values contain any NaN.
%         - normally, NaN never occurred.
% 
% Dependency: 
% - split1dArrayByThreshold.m

funNm = '[splitted1dArrayStatistics]';
% expectedCheck = {'CheckLong'}; % order must right
% valid_ck = @(x) any(validatestring(x,expectedCheck));

p = inputParser;
addParameter(p,'MemoryLimit',0);
addParameter(p,'Threshold',0.01);
addParameter(p,'Validation',{});
addParameter(p,'matfileSave',0);
% addParameter(p,'DataFit',0);
parse(p,varargin{:});
rst = p.Results;
memoryLimit = rst.MemoryLimit;
thr = rst.Threshold;
Validation = rst.Validation;
% FitType = rst.DataFit;
matfileSave = rst.matfileSave;


if isequal(memoryLimit,0)
    % estimate appropriate array size to be load a time according to memory.
    memoryLimit = limitnumel(0.0005,'double'); 
else
    memoryLimit = floor(memoryLimit); % to avoid error.
end

%%
checkLong = false;


if any(ismember({'CheckLong','checkLong'},Validation))
    checkLong = true;
end

fprintf('%s Cut-off threshold: %.6f \n',funNm,thr);

sizeT = size(matfile1,'Y'); % Don't use "size(mtf.traceT)"


issaveasmatfile = ~isequal(matfileSave,0);
if issaveasmatfile
    if ischar(matfileSave) || isStringScalar(matfileSave)
        if isfile(matfileSave)
            matfileSave = pathnonrepeat(matfileSave);
            disp('[splitted1dArrayStatistics] Matfile for S exist, create a new file.');
        end
    else
        matfileSave = pathnonrepeat('temp.mat');
        fprintf('Save the file to %s in the current directory. \n',matfileSave);
    end
    S = matfile(matfileSave);    % S.Properties.Writable must hence be true.
    if ~S.Properties.Writable
        error('S.Properties.Writable is false. This should not happen.');
    end

else
    S = struct();    
end

[columnNames] = calc_stat();
lennames = length(columnNames);
for i = 1:lennames
    S.(columnNames{i}) = [];
end

try
    [outputTable] = matfileWhos(matfile1); % information of the input timeseries
    S.Info = outputTable;
catch
    warning('Failed in matfileWhos. There will be no information of this matfile.');
end

maxlength = max(sizeT);
maxiters = ceil(maxlength/memoryLimit);
prev_seg_tail_not_finished = false; % the last segment in the previous iteration is not falled inside threshold yet.
this_first_seg_is_outside = false; % the first segment in this iteration is outside threshold.

% fix the bug 2020-05-27
% id0 = 1;
% id1 = 1 +memoryLimit;
id0 = 1 - memoryLimit;
id1 = 1;

stats = [];



tic; H = timeLeft0(maxiters,funNm);
for i = 1:maxiters 

    stats_tmp_f = [];
    % for the long segment that cross more-than-one iterations.
    % If the long segment is not complete yet, 
    % duration_tmp should remain empty.
    % Unfinished duration are summed up and temporarily
    % stored in stats_tmp_part
    
    id0 = id0+memoryLimit;
    id1 = min([id1 + memoryLimit, maxlength]);
    if id0>=id1 % then it will return empty indices that will cause error. In fact previous loop is the last loop.
        fprintf('[%s] Previous loop is the last loop. Iteration i = %d break.\n',funNm,i);
        break
    end
    Yi = matfile1.Y(id0:id1,1);
    [segments_all,outside_id,inside_id,durations_all] = split1dArrayByThreshold(Yi,thr);
    % Segments_all(outside_id) is segs_outside,
    % segments_all(inside_id) is segs_inside.
    % As follow:
    %    segs_outside = segments_all(outside_id);
    %    segs_inside = segments_all(inside_id);

    no_inside = isempty(inside_id);
    % no value falls below/inside the threshold in this iteration. 
    no_outside = isempty(outside_id);
    % all values are below/inside the threshold in this iteration. 
    
    if no_outside || outside_id(1) ~= 1 % this-first-segment is not outside.
        % outside_id can be either 1:2:end or 2:2:end,
        % hence, outside_id(1) == 1 means the 1st segment is outside
        % threshold.
        this_first_seg_is_outside = false;
        if prev_seg_tail_not_finished
            warning("%s [RARE EVENT!] (You shouldn't see this frequently) Restore the previous deleted one to this iter.",funNm);
        end
    else % outside_id(1) == 1
        this_first_seg_is_outside = true;
    end
    

    
    if prev_seg_tail_not_finished && this_first_seg_is_outside
           
        [stats_tmp2] = calc_stat(segments_all,outside_id(1),durations_all);
        % stats_tmp2 is 1 by 3, the statistics of the first segment 
        % (which must be the continuation of the last incompleted one).
        % To calculate statistics of segments inside the threshold, change
        % outside_id into inside_id, as follow:
        %   [stats_tmp2] = calc_stat(segments_all,inside_id,durations_all);
          
        stats_tmp_part = stats_tmp_part + stats_tmp2;
        % stats_tmp_part is created in the previous loop if
        % the last segment in previous loop is not finished.
        outside_id(1) = []; 
        % remove the 1st segment since it has been taken into accounted
        % in stats_tmp2.
        if no_inside 
            % prev_seg_tail_not_finished && this_first_seg_is_outside 
            % && no_inside:
            % That is, previous event still incomplete until the end of
            % this session (only one outside = all datapoints are outside).
            % (PS: 'incomplete' means the process do not fall 'inside' yet)
            if checkLong && length(segments_all)>1 
                tlt2 = 'Long process that keeps going in this loop';
                error([tlt2,'. Error: numel seg is not right.']);
            end
            continue  
            % ONLY 1 segment: very probably this segment is not completed yet.
            % stats_tmp_part are passed into next iteration
        else % previous long time series terminates in this loop
            stats_tmp_f = stats_tmp_part;
            % if prev_seg_not_finished && this_first_seg_is_outside...
            % && previous long timeseries terminates in this loop,
            % stats_tmp_f is the statistics of the finished long timeseries
            % that cross two loops.
        end        
    end
    
    try
        prev_seg_tail_not_finished = no_inside || outside_id(end) > inside_id(end);
        % True if the last segment (tail) in this iteration is outside 
        % thresholds, i.e. incompleted/unfinished.
    catch ME
        if strcmp(ME.identifier,'MATLAB:badsubscript')
        % outside_id isempty, hence error occurred.
        prev_seg_tail_not_finished = false; 
        % (for the next loop) This 
        % indicates the last segment in the previous loop is completed.
        else 
            rethrow(ME);
        end
    end
    
    if  prev_seg_tail_not_finished       
        % if the i-1th seg_last is not all nan (which means it's not finished yet)
        % save and pass the last unfinished segment to next iteration.
        [stats_tmp_part] = calc_stat(segments_all,outside_id(end),durations_all);
        % calculate the duration of unfinished segment (seg_tail) that will
        % be passed to the next loop.
        outside_id(end) = []; % this is required
        % temporarily save the duration of the incompleted time series as duration_tmp_1, 
        % and delete the incompleted one that it won't be counted as duration_i.
    else % tail segment is incomplete in previous iteration
        stats_tmp_part = []; % this is unnecessary since
                             % stats_tmp_part = stats_tmp_part + stats_tmp2
                             % can be reached only if prev_seg_not_finished is true.
    end

    % Calculate statistics of this iteration
    [stats_i] = calc_stat(segments_all,outside_id,durations_all);
    stats = [stats;stats_tmp_f;stats_i];
    
    if issaveasmatfile
        len_S_tmp = size(stats,1);
        if len_S_tmp > memoryLimit || i == maxiters % then save to matfile
            len_S = size(S,columnNames{1},1);
            S_id0 = len_S + 1;
            S_id1 = len_S + len_S_tmp;
            indS = S_id0:S_id1;
            if ~isempty(indS)
                % matfile does not support index to be empty
                % indS is empty only if length(duration) is zero
                for nmi = 1:lennames
                    colname_i = columnNames{nmi};
                    S.(colname_i)(indS,1) = stats(:,nmi);
                end           
                stats = []; % and release the memory.
            else
                % if length(duration) is zero, then there's no need to
                % write anything to matfile. 
            end

        end
    end
    [H] = timeLeft1(toc,i,H);
end
delete(H.waitbarHandle);

if ~issaveasmatfile
    for nmi = 1:lennames
        colname_i = columnNames{nmi};
        S.(colname_i) = stats(:,nmi);
    end
else
    % do nothing, since the variables already saved.
end

S.threshold = thr;

end

function [stats_output] = calc_stat(segments_all,target_id,durations_all)
% [stats_outside] = calc_stat(segments_all,outside_id,durations_all)
% [stats_inside] = calc_stat(segments_all,inside_id,durations_all)
% [columnNames] = calc_stat()
funcs = {''            ,@(seg_k) sum(abs(seg_k)),@(seg_k) sum(seg_k)};
funcNames = {'duration','sumabsY'               ,'sumY'};

if nargin == 0
   stats_output = funcNames;
   return
end

width_stat = length(funcNames);% number of statistics to be calculated

NoSeg = length(target_id);
stats_output = NaN(NoSeg,width_stat);

% the first statistics is the durations
stats_output(:,1) = durations_all(target_id);

for k = target_id
    seg_k = segments_all{k};
%     duration_i(k) = length(seg_k);% calculate duration
    for i = 2:width_stat 
        func_i = funcs{i};
        stats_output(:,i) = func_i(seg_k);
%         This will do tasks like:
%             stats(:,2) = sum(abs(seg_k)); % calculate sum(v.*dt)
%             stats(:,3) = sum(seg_k);% calculate the sum of velocity
    end
end
end

