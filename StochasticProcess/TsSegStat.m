function [S] = TsSegStat(matfile1,varargin)
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
% - split_by_thr.m
% 
% Last modify: Hsi 2020-05-27

funNm = '[TsSegStat]';

expectedCheck = {'CheckLong','CheckJump','CheckNaN'}; % order must right
% valid_ck = @(x) any(validatestring(x,expectedCheck));

p = inputParser;
addParameter(p,'MemoryLimit',0);
addParameter(p,'Threshold',0.01);
addParameter(p,'Validation',0);
addParameter(p,'DataFit',0);
parse(p,varargin{:});
rst = p.Results;
memoryLimit = rst.MemoryLimit;
thr = rst.Threshold;
Validation = rst.Validation;
FitType = rst.DataFit;

if isequal(memoryLimit,0)
    % estimate appropriate array size to be load a time according to memory.
    memoryLimit = limitnumel('double'); 
else
    memoryLimit = round(memoryLimit); % to avoid error.
end

%%
if isequal(FitType,0)
    do_fit = false;
else
    do_fit = true;
end
checkLong = false;
checkJump = false;
checkNaN = false;
if ismember(expectedCheck{1},Validation)
    checkLong = true;
    NumelSegsIsNotRight = 0;
end
checkLongCount = 0; % must have

if ismember(expectedCheck{2},Validation)
    checkJump = true;
    checkJumpCount = 0;
end

if ismember(expectedCheck{3},Validation)
    checkNaN = true;
end

fprintf('%s Cut-off threshold: %.6f \n',funNm,thr);

sizeT = size(matfile1,'X'); % Don't use "size(mtf.traceT)"

[outputTable] = matfileWhos(matfile1);
S = struct();
S.Info = outputTable;




maxlength = max(sizeT);
maxiters = ceil(maxlength/memoryLimit);
prev_seg_not_finished = false;
this_first_seg_not_NaN = false;

% fix the bug 2020-05-27
% id0 = 1;
% id1 = 1 +memoryLimit;
id0 = 1 - memoryLimit;
id1 = 1;

duration = [];
avgY = [];
vsquare = [];

tic; H = timeLeft0(maxiters,funNm);
for i = 1:maxiters %i = maxiters goes wrong.
    duration_tmp = [];
    vsquare_tmp = [];
    avgY_tmp = [];
    
%     tY =  [1;2;4;6;8];
    id0 = id0+memoryLimit;
    id1 = min([id1 + memoryLimit, maxlength]);
    if id0>=id1 % then it will return empty indices that will cause error. In fact previous loop is the last loop.
        fprintf('[%s] Previous loop is the last loop. Iteration i = %d break.\n',funNm,i);
        break
    end
        tY = matfile1.Y(id0:id1,1);
%     [Y_seg,idx] = split_SDE(tY);
    [segments_all,desired,undesired] = split_by_thr(tY,thr);

    seg_last = segments_all{end};
    seg_first = segments_all{1};
    
    if all(isnan(seg_first)) % if first segment is nan, then no need to combine with the previous one. (rarely happen)
        % all is faster than any
        this_first_seg_not_NaN = false;
        if prev_seg_not_finished
%             desired = [{previous_last_seg};desired]; % restore the previous deleted one to this iter.
            warning('%s [RARE EVENT!] Restore the previous deleted one to this iter.',funNm);
        end
    else
        this_first_seg_not_NaN = true;
    end
    
    no_undesired = isempty(undesired);
    
    if prev_seg_not_finished && this_first_seg_not_NaN
        
%             previous_last_seg = [previous_last_seg; desired{1}]; 
            
        [duration_tmp_2,vsquare_tmp_2,avgY_tmp_2] = calc_stat(desired(1),false);
        % duration_tmp_1 is created in the previous loop if
        % the last segment in previous loop is not finished.

        duration_tmp_1 = duration_tmp_1 + duration_tmp_2;
        vsquare_tmp_1 = vsquare_tmp_1 + vsquare_tmp_2;
        avgY_tmp_1 = avgY_tmp_1 + avgY_tmp_2;


        if checkLong &&  i >= maxiters/2
            if checkLongCount<12
                figure;
                plot(segments_all{1});
                tlt2 = 'Long process that keeps going in this loop';
                title(tlt2);
                drawnow;
            end
        end
        if no_undesired % still not finished (only one desired = all datapoints are desired in this session)    
            if checkLong && length(segments_all)>1 
                warning([tlt2,'. Also, numel seg is not right.']);
                NumelSegsIsNotRight = NumelSegsIsNotRight+1;
            end
            continue  % ONLY 1 segment: very probably the this segment is not completed yet.
        else % previous long time series terminates in this loop
            duration_tmp = duration_tmp_1;
            vsquare_tmp = vsquare_tmp_1;
            avgY_tmp = avgY_tmp_1;
            desired(1) = []; % remove the 1st segment since it has been taken into accounted.
            checkLongCount = checkLongCount+1;
        end        
    end
    
    if checkJump
        for k = 1:length(desired)
            if any(diff(desired{k})>1)
                warning('%s Combined error, index %d:%d',funNm,id0,id1);
                checkJumpCount = checkJumpCount+1;
                if checkJumpCount<5
                    figure;
                    title(sprintf('%s Combined error, index %d:%d',funNm,id0,id1));
                    plot(desired{k});
                    drawnow;
                end
%                 pause;
            end
        end
    end

    %
    if all(isnan(seg_last))% all is faster than any
        prev_seg_not_finished = false; % segment finished.
        
        vsquare_tmp_1 = 0; % this is unnecessary
        avgY_tmp_1 = 0; % this is unnecessary
        duration_tmp_1 = 0; % this is unnecessary since 
                                                    % duration_tmp_1 = duration_tmp_1 + duration_tmp_2
                                                    % can be reached only if prev_seg_not_finished is true.
    else % segment not finished.
        % if the i-1th seg_last is not all nan (which means it's not finished yet)
        prev_seg_not_finished = true; % save and pass the last unfinished segment to next iteration.
%         previous_last_seg = seg_last;       
        [duration_tmp_1,vsquare_tmp_1,avgY_tmp_1,~] = calc_stat({seg_last},false);
        
        segments_all(end) = [];
        desired(end) = [];
    end
    %      TsAnimation(cell2mat(desired),'WindowWidth',100);

    % Calculate statistics   
    [duration_i,vsquare_i,avgY_i] = calc_stat(desired,do_fit);
    duration = [duration;duration_tmp;duration_i]; 
    % if prev_seg_not_finished && this_first_seg_not_NaN...
    % && previous long timeseries terminates in this loop,
    % duration_tmp is the duration of the long timeseries that cross loops.
    % Otherwise, it is empty.
    vsquare = [vsquare;vsquare_tmp;vsquare_i];
    avgY = [avgY;avgY_tmp;avgY_i];
    [H] = timeLeft1(toc,i,H);
 
end
delete(H.waitbarHandle);

S.vsquare = vsquare;
S.duration = duration;
S.threshold = thr;
S.average = avgY;

if checkNaN
    try
        S.checkNaN = 'NaN check passed.';
        if any(isnan(duration))||any(isnan(vsquare))||any(isnan(avgY))
            S.checkNaN = 'NaN check NOT passed.';
        end
    catch
        S.checkNaN = 'NaN check NOT passed.';
    end
    
end

if checkJump
    S.checkJumpCount = checkJumpCount;
end
S.checkLongCount = checkLongCount;

if checkLong
    S.NumelSegsIsNotRight = NumelSegsIsNotRight;
end



end

function [duration_i,vsquare_i,avgY_i,NoSeg] = calc_stat(time_series_in_cell,do_fit)
NoSeg = length(time_series_in_cell);

nan_i = NaN(NoSeg,1);
duration_i = nan_i;
vsquare_i = nan_i;
avgY_i = nan_i;
for k = 1:NoSeg
    seg_k = abs(time_series_in_cell{k}); % before 2020-06-09, there is no abs().
    duration_i(k) = length(seg_k);% calculate duration
    vsquare_i(k) = sum(seg_k.^2);% calculate kinetic energy (without 0.5*mass)
    avgY_i(k) = mean(seg_k);% calculate mean
    if do_fit && duration_i(k)>1e4
        [CCDF,umax,u] = calc_CCDF(seg_k);
        DF1 = DataFit(u,CCDF,'TEX(CCDF)','umax',umax);
        DF2 = DataFit(u,CCDF,'EXP(CCDF)');
        figure;
        DataFitPlot(u,CCDF,{DF1,DF2},'YScale','log',...
            'Legend',{'data',sprintf('TEX with u_c = %.2f',DF1.best_fit_coeff),'EXP'},...
            'XLabel','Y','YLabel','CCDF(Y)'); 
        figure;
        plot(seg_k);
        xlabel('t'); ylabel('y');
        drawnow;
    end
end
    
end
