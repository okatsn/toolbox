
%% Efficiency test

%% Template
iters = 10000;
tic;
for i = 1:iters

end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters

end
fprintf('2: %.6f sec \n',toc);
%%
iters = 1000000;
tic;
Summary2.warning = struct;
for i = 1:iters
    isfield(Summary2.warning,'MolchanScoreNaN');
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters
    ischar(RankedModelsBestRand.MS);
end
fprintf('2: %.6f sec \n',toc);
%% Template
iters = 1000000000;
tic;
for i = 1:iters
    if sign(12) > 0
    end
    
    if sign(-12) > 0
    end
    
    if sign(12) < 0
    end
    
    if sign(-12) < 0
    end
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters
    if sign(-12) == 1
    end
    
    if sign(-12) == -1
    end
    
    if sign(12) == 1
    end
    
    if sign(12) == -1
    end
end
fprintf('2: %.6f sec \n',toc);

%% Template
iters = 10000;
tic;
for i = 1:iters
    Athr_i = Athr_mod(iMod);
    if Athr_i - Athr_k ~= 0
        [~, ~] = update_tsAIN(Athr_i,tsAIN_table);
    end
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters 
    if Athr_mod(iMod)-Athr_k ~= 0 % if Athr changed.
        Athr_k = Athr_mod(iMod);      % then update Athr_i
        idxAthr = tsAIN_table.Athr == Athr_k;
        tsAIN_k = tsAIN_table(idxAthr,:); % and update the tsAIN
        [cell_tsAIN_k,~] = fieldsFind(tsAIN_k,'tsAIN');
        sum_tsAIN_k = sum(cell2mat(cell_tsAIN_k),2);
    end % this if...end will dramatically increase speed.
%     Athr_k = -1; % only in speedTest
end
fprintf('2: %.6f sec \n',toc);


%% Days
iters = 1000000;
tic;
for i = 1:iters
    days(Tlead_mod);
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters

end
fprintf('2: %.6f sec \n',toc);



%% sortrows
iters = 100;
tic;
for i = 1:iters
    [A,ida] = sortrows(CWBcatalog,'DateTime'); 
end % ~0.57 sec 
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters
    CWBcatalog.DateTime(1)>CWBcatalog.DateTime(end);
end % 20 times faster. ~0.02sec
fprintf('2: %.6f sec \n',toc);



%%
total_iters = 10000000;
tic; H = timeLeft0(total_iters,'SpeedTest');
for i = 1:total_iters
    [H] = timeLeft1(toc,i,H);
end

%%
iters = 10000;
h = waitbar(0,'test');
tic; previous_tocs = NaN(1,total_iter); %out of loop
for i = 1:iters
    [previous_tocs,timeElapsed,timeLeft] = timeLeft(this_toc,previous_tocs,this_iter,total_iters,h);
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters

end
fprintf('2: %.6f sec \n',toc);
%% Template
iters = 10000;
A = [1:100000];
tic;
B1 = A;
for i = 1:iters
    B1 = [B1,i];
end
fprintf('1: %.6f sec \n',toc);

tic;
C = [];
for i = 1:iters
    C = [C,i];
end
B2 = [A,C];
fprintf('2: %.6f sec \n',toc);

%%
iters = 100000;
tic;
for i = 1:iters
    any(isnan(segments_all{end}));
end
fprintf('1: %.6f sec \n',toc);

tic;
for i = 1:iters
    all(isnan(segments_all{end}));
end
fprintf('2: %.6f sec \n',toc);

%% plus/max
a = 854;
tic;
for i = 1:100000
    b = max([a,i]);
end
toc;

tic; % overwhelming faster
for i = 1:100000
    b = i +0.1;
end
toc;

tic; % overwhelming faster
for i = 1:100000
    b = i +a;
end
toc;
%% multiple/divide
iters =100000000;
tic;
for i = 1:iters
    a = i*2.7778e-04;
end
toc;

tic;
for i = 1:iters
    a = i/3600;
end
toc;

%% wait bar
h = waitbar(0,'Initializing...');
tic;
NoI = 10000;
a=0;
for i = 1:NoI
    perc = i/NoI;
    a = a+1;
    if a>200
        a = 0;
        waitbar(perc,h,'Now progressing...');
    end
end
toc;

tic;
for i = 1:NoI
    perc = i/NoI;
end
toc;

%%
tic;
for i = 1:1000
    previous_saved_mat_list = datalist([fnm1,'*.mat'],pwd,'Basic',1);
end
toc;

tic;
for i = 1:1000
    previous_saved_mat_list = datalist([fnm1,'*.mat'],pwd);
end
toc;

%%

tic;
for i = 1:100000
    if mod(i,5000)==0|| i ==100000
%         disp(i);
    end
end
toc

tic;
tempidx = 5000;
for i = 1:100000
    if i == tempidx || i ==100000
%         disp(i);
        tempidx = tempidx+5000;
    end
    
end
toc


%%
%% for large array, especially table, copy variable before calculation increase speed.
testlist0 = randi(100,[100000,8]);
testlist = array2table(testlist0);
tic;
for i = 1:100000
    a = testlist{i,7} + testlist{i,6};
end
toc


tic;
c7 = testlist{:,7};
c6 = testlist{:,6};
for i = 1:100000
    a = c7(i)+c6(i);
end
toc


tic;
for i = 1:100000
    c7i = c7(i);
    c6i = c6(i);
    a= c7i+c6i;
    
end
toc

%%
testlist = randi(100,[100000,8]);
tic;
for i = 1:100000
    a = testlist(i,7) + testlist(i,6);
end
toc


tic;
c7 = testlist(:,7);
c6 = testlist(:,6);
for i = 1:100000
    a = c7(i)+c6(i);
end
toc


tic;
for i = 1:100000
    c7i = c7(i);
    c6i = c6(i);
    a= c7i+c6i;
    
end
toc

%%
tic; 
for i =1:10000 
catalog0 = CWBcatalog;
catalog0 = catalog0(midx,:);
end 
toc
%Elapsed time is 21.606352 seconds.

tic; 
for i =1:10000 
catalogm = CWBcatalog(midx,:);
end 
toc
%Elapsed time is 21.868091 seconds.

A = cell(10000,1);
tic; 
for i =1:10000 
A{i} = CWBcatalog;
end 
toc
%Elapsed time is 0.009221 seconds.

tic; 
for i =1:10000 
Depth = CWBcatalog.Depth;
end 
toc
% Elapsed time is 0.225999 seconds.

% faster to copy a certain variable from table before entering for loop.
tic; 
for i =1:10000 
C = CWBcatalog.Depth.^2;
end 
toc
% Elapsed time is 0.669769 seconds.

tic; 
for i =1:10000 
C = Depth.^2;
end 
toc
% Elapsed time is 0.151672 seconds.

%% 
tic;
for i = 1:10000
    
    if isa(0,'matlab.graphics.axis.Axes')
        % do nothing
    end
end
toc

%%
tic;
for i = 1:10000
    validpath('123dfg');
end
toc

tic;
for i = 1:10000
    bkvalidpath2('123dfg');
end
toc

%%
tic;
for i =1:10000
    table2array(pt(1,:));
end
toc

%% copy variable from tabel first outside the loop will increase speed.
Nthr_mod = pt.Nthr;
[NoR,~] = size(Nthr_mod);
NoC = 10000;
A = NaN(NoR,NoC); B = NaN(NoR,NoC);
tic;
for i = 1:NoC
    A(:,i) =pt.Nthr;
end
toc

tic;
for i = 1:10000
    B(:,i) =Nthr_mod;
end
toc


%% nModel = 700000
Athr_i = 0;
Athrlisttest = [];
tic;
for iMod = 1:nModel
  if Athr_mod(iMod)-Athr_i ~= 0 % if Athr changed.
      Athr_i = Athr_mod(iMod);      % then update Athr_i
      idxAthr = tsAIN_table.Athr == Athr_i;
      tsAIN_i = tsAIN_table(idxAthr,:); % and update the tsAIN
%       [sum_tsAIN_i,fieldNms] = fieldsFind(tsAIN_i,'tsAIN');
       Athrlisttest = [Athrlisttest,Athr_i];
  end



end
toc
%%
tic;
anoTM=0;
for i = 1:100000
    
if ~0
%      disp('do')
anoTM= anoTM+1;
end
end
toc


%% Template
tic;
% anoTM = [1,2,3];
for i = 1:10000
%     any(isnan(anoTM));
    nansum(anoTM);
end
toc

tic;
for i = 1:10000
    sum(anoTM);
end
toc

%%
a = linspace(1,10000,1999999);
N = numel(a);
b = [1,N];
tic;
for i = 1:10000
    max(b);
end
toc

tic;
for i = 1:10000
    length(a); 
end
toc

%% Templaye
a = 0.5;
b = 0.01*randi(100,[1 10]);
tic;
for i = 1:10000
    [idxxx1,ivalue1] = nearest1d(b,a);
    
end
toc

tic;
for i = 1:10000
    [idxxx2,ivalue2] = nearestBelow(b,a);
    
end
toc


%%
char1 = 'default';
value1 = 0;

tic;
for i = 1:100000
    strcmp(char1,'default');
end %fast enough
toc
tic;
for i = 1:100000
    isequal(value1,0);
end %much faster
toc
%%
axxx = 'matlab.graphics.axis.Axes';
tic;
for i = 1:10000
     isa(axxx,'matlab.graphics.axis.Axes');
end
toc

tic;
for i = 1:10000
     strcmp(axxx,'matlab.graphics.axis.Axes');
end
toc
%%
classaxxx = 'logical';
tic;
for i = 1:1000000
     isa(classaxxx,'logical');
end
toc

tic;
for i = 1:1000000
     strcmp(classaxxx,'logical');
end
toc

%% Templaye
strcell = {'DateNum','tsAIN_S','tsAIN_K','tsAIN_mu','tsAIN_V','Athr'};
old = 'tsAIN';
repby = 'ULthr';
tic;
for i = 1:100000
    A = regexprep(strcell,old,repby);
    
end
toc
tic;
for i = 1:100000 %3 times faster
    B = strrep(strcell,old,repby);
end
toc


%% Templaye
tic;
for i = 1:10000
        [vlSAT,idx4t] = MovingWindowSum(anoTM,Tobs_mod(iMod));
end
toc

%% Templaye
tic;
for i = 1:1000000
     if isfield(A,'ConfidenceInterval')
         a=1;
     end
end
toc

tic;
for i = 1:1000000
     if isequal(1,2)
         a=1;
     end
end
toc

%% Template
tic;
for i = 1:100
    M = importdata(target_dir);
end
toc

tic;
for k = 1:100
    for i = 1:NoSt
        StNm = StNms{i};
    O.(StNm).GMPs.S(k) = 1000;
    end
end
toc

%% Template
A = randn(1,10000);
tic;
for i = 1:100000
    B = A(:);
end
toc

tic;
for i = 1:100000
    B = trans2vert(A);
end
toc


%% display every...

tic;
a = 0;
b = 100000000;
c1 = 0; c2 = c1; c3 = c1;

for i = 1:b % faster (3 times) than rem
    a= a+1;
    if a>5000
        a=0;
        c1 = c1+1;
%         fprintf('now in loop %d\n',i);
    end
end
toc

tic;
for i = 1:b
    if rem(i,5000) == 0
        c2 = c2+1;
%         fprintf('now in loop %d\n',i);
    end
end
toc


tic
A = now;
t0 = now;
for i = 1:b %very time consuming, never use this
    ttoc = toc;
    if ttoc>1
        tic;
        c3 = c3+1;
%         fprintf('now in loop %d\n',i);
    end
end
B = now;

%%
tic;
t0 = clock;
for i = 1:10000
    t1 = clock;
    etime(t1,t0);
end
toc;