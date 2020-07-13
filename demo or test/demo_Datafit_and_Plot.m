% demo_Datafit_and_Plot

%% Generate X,Y and umax

% % SRCMOD rupture model
% [ srcmodDATA ] = LoadFile0( 47 );
% O2016 = TEX_EQ_slip(srcmodDATA,0); % old 'instruction'
%  X=O2016.u; Y = O2016.CCDF;
%  umax = O2016.umax;

% %  Just to check EXP fit is OK. (Verified 12/18)
% X = linspace(1,500,500); X=X';
% Y = exp(-X);
% umax = max(Y);

% Sample path
D = 5.34; r=1; totalTime = 10; FrictionType = 'dry';
O = EulerSDE_a(D,r,totalTime,'Plot_',1,'FrictionType',FrictionType,'smooth','100000pt');
% [CCDF,umax,u] = calc_CCDF(O.traceY); Y=CCDF; X=u;
input_M = abs(O.Y);
[CCDF,umax,u] = calc_CCDF(input_M); Y=CCDF; X=u;
%umax2 = max(O.traceY);

%%%%%%%%%%%%%%ABS O.traceY is needed;


%% DataFit and Plot (Dry)
DF1 = DataFit(X,Y,'TEX_CCDF','umax',umax);
DF2 = DataFit(X,Y,'EXP');
DF3 = DataFit(X,Y,'erf_CCDF','umax',umax);

%% save variable
save_to_folder = fullfile(pwd,'variable');
addpath(fullfile(fileparts(pwd),'demo_script')); mkdir_if_not_exist(save_to_folder);
fname = sprintf('D=%.2f-r=%.2f-FT=%s-T=%.1e.mat',D,r,FrictionType,totalTime);
target_dir_1 = fullfile(save_to_folder,fname);  save(target_dir_1);

%%
figure;DataFitPlot(X,Y,'yscale_','log');
figure;DataFitPlot(X,Y,{DF1},'legend_',{'data','TEX(dry)'},'yscale_','log');
figure;DataFitPlot(X,Y,{DF1,DF2,DF3},'legend_',{'source data','best TEX fit','best EXP fit','best erf fit'},'yscale_','log');
figure;DataFitPlot(X,Y,{DF1,DF2,DF3});

%% DataFit and Plot (wet)

FrictionType = 'viscous';
t1 =  sprintf('data fitting to sample path under %s regime',FrictionType);
O = EulerSDE_a(D,r,totalTime,'Plot_',1,'FrictionType',FrictionType,'smooth','100000pt');
input_M = abs(O.Y);
[CCDF,umax,u] = calc_CCDF(input_M); Y=CCDF; X=u;
DF1 = DataFit(X,Y,'TEX_CCDF','umax',umax);
DF2 = DataFit(X,Y,'EXP');
DF3 = DataFit(X,Y,'erf_CCDF','umax',umax);
DataFitPlot(X,Y,{DF1,DF2,DF3},'yscale_','log','title_',t1);

%% save variable
save_to_folder = fullfile(pwd,'variable');
addpath(fullfile(fileparts(pwd),'demo_script')); mkdir_if_not_exist(save_to_folder);
fname = sprintf('D=%.2f-r=%.2f-FT=%s-T=%.1e.mat',D,r,FrictionType,totalTime);
target_dir_1 = fullfile(save_to_folder,fname); save(target_dir_1);