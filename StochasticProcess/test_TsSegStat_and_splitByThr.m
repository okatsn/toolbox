%% test split_by_thr and TsSegStat
% How to use:
% - test_TsSegStat_and_splitByThr(); 
%     - test on auto-generated stochastic process once.
% - test_TsSegStat_and_splitByThr(n); 
%     - test on auto-generated stochastic process n times.
% - test_TsSegStat_and_splitByThr(amatfilepath); 
%     - test on a stored time series, with the matfile containing field 'X' and 'Y';
function test_TsSegStat_and_splitByThr(varargin)
nopass = 0;
if nargin > 0
    firstArg = varargin{1};
    if isscalar(firstArg)
        for i = 1:firstArg
            fprintf('Run %d/%d: \n',i,firstArg);
            test_TsSegStat_and_splitByThr();
        end
        return
    elseif isfile(firstArg)
        error('supporting for testing on matfiles is still under construction.');
        mtf = matfile(varargin{1});
        Y = mtf.Y;
        % not finished yet.
        
    end
else
    DrY0 = 10*rand(1,3).*randn(1,3);
    ConstantForce = abs(randn());
    dt = 1e-3;
    tempfilename = 'temp_EulerSDE.mat';
    if isfile(tempfilename)
        error('previous temporary file does not be deleted properly.')
    end
    
    disp('Preparing test...');
    O = EulerSDE_a(abs(DrY0(1)),abs(DrY0(2)),50000,DrY0(3),dt,'ConstantForce',ConstantForce,...
        'SaveInplace',tempfilename);
    Y = O.Y;
    maxY = max(abs(Y));
    thr_test1 = [-1e19 0];
    [segments_all,desired,undesired] = split_by_thr(Y,0);
    [segments_all2,desired2,undesired2] = split_by_thr(Y,[-1e19 0]); % they should be the same.
%     test 1:
    condition1 =  sprintf('thr = 0 and [%.2e %.2e]',thr_test1(1),thr_test1(2));
    fprintf('Test 1: testing split_by_thr with %s.\n',condition1);
    
    
    
    if ~isequaln(segments_all,segments_all2)
        warning("Test 1-1 failed ('segments_all' not identical for %s)",condition1);
        nopass = nopass+1;
    end
    
    if ~isequaln(desired,desired2)
        warning("Test 1-2 failed ('desired' not identical for %s)",condition1);
        nopass = nopass+1;
    end
    
    if ~isequaln(undesired,undesired2)
        warning("Test 1-3 failed ('undesired' not identical for %s)",condition1);
        nopass = nopass+1;
    end
    
    % test 2: NaN/empty and non-NaN/non-empty cell should
    % occurred in turn.
    fprintf('Test 2: testing whether NaN/empty and non-NaN/non-empty arrays in segments_all occurred in turn. \n.');
    thr = 0.2*randn(1,randi(2));
    if length(thr)>1 && thr(1)*thr(2)>0 % if zero does not lie between thr 
        % (i.e. thr(1) & (2) has the same sign)
        thr(2) = -1*thr(2); % make thr(2) the opposite sign of the first one.
    end
    [segments_all] = split_by_thr(Y,thr);
    isnanorempty = @(x) all(isnan(x)) | isempty(x);
    A_isallnanorempty = cellfun(isnanorempty,segments_all);
    A_expected = ones(size(A_isallnanorempty));
    if A_isallnanorempty(1) == 1 % first cell is empty/nan
        A_expected(2:2:end) = 0;
    else % A(1) == 0 % first cell is not empty/nan
        A_expected(1:2:end) = 0;
    end
    if isequal(A_isallnanorempty,A_expected)
        disp('Test 2 passed. NaN/empty and non-NaN/non-empty cells occurred in turn.');
    else
        warning('Test 2 not passed. NaN/empty and non-NaN/non-empty cells are not occurred in turn.');
        nopass = nopass+1;
    end
    
    fprintf('Test 3: split_by_thr using different approaches and calculates statistices.');
    h_split = 0;
    thr2 = [h_split,h_split+1e-18];
    tempfilename2 = pathnonrepeat(tempfilename);
    mtf1 = matfile(tempfilename); 
    mtf2 = matfile(tempfilename2);
    mtf2.Y = -mtf1.Y;
    S1 = TsSegStat(mtf1,'Threshold',h_split);
    S2 = TsSegStat(mtf2,'Threshold',-h_split);
    S = TsSegStat(mtf1,'Threshold',thr2);
    duration1 = sort(S.duration);
    vsquare1 = sort(S.vsquare);
    duration2 = sort([S1.duration;S2.duration]);
    vsquare2 = sort([S1.vsquare;S2.vsquare]);
    if isequal(duration1,duration2) && isequal(vsquare1,vsquare2)
        disp('Test 3 passed.');
    else
        warning('Test 3 not passed.');
        nopass = nopass+1;
    end
 
    if nopass == 0
        disp('All tests passed.');
        delete(tempfilename);
        delete(tempfilename2);
    else
        disp('At least one of the tests not passed. The session will pause 20 seconds.');
        disp('Please set debug point in the line below to see what happen.');
        
        pause(20);
        disp('20 seconds passed. Exit the testing.')
        error('Please see the temporarily saved matfile, and manually delete these files.')
    end
    
    
    
    
end

end
