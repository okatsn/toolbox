%% GM SOP 2019
% THIS SCRIPT WORKS WITH dataset in 2020 (dataset 'Set_15', 'Set_16' and...)

% if you want run the entire script at once, please use SOP_2019_Batch to
% call this script from outside.

% Note:
% # Time cut in tsAIN table according to TIP_time.range_forecast in %% GEMSTIP Joint station method.
% # Time cut in tmSeq in %% GEMSTIP Joint station method


%% Setting and load data (do this before any action)
if ~exist('CallFromOutSide','var') || CallFromOutSide == false
    CallFromOutSide = false;
else
    CallFromOutSide = true; % this is unnecessary.
end

if ~CallFromOutSide % parameter setting in this session (if not called from outside)
    import init_cwb.* % go to the folder 'init_cwb' to change the values of variables.
    set_x = init_cwb.set_0; % this contains read-only variables.
    i_outside = 1; % trn1 = [trn_0, data_end]
    k_outside = 1;
    [settings_cwb] = what2do_cwb('Do',{'GMPoD','JointStation','Plot'});
    SkipExistingRankedModels = false; % default is to overwrite them all.
end
trn_0 = set_x.trn_0; %datetime("20061115",'inputFormat','yyyyMMdd');
trn_1 = set_x.trn_1(i_outside); %datetime("20151114",'inputFormat','yyyyMMdd');
data_end = set_x.data_end; % datetime("20190415",'inputFormat','yyyyMMdd');
MvWin = set_x.MvWin; %[1000];% MvWin = [200,500,1000]; Moving window of AINbase Section
varNms = set_x.varNms; %{'S','K'};
dataset_i = set_x.dataset_i;% 'Set_13';
SKMVtype = set_x.SKMVtypes{k_outside};%'not filtered';
PredParamSetting = set_x.PredParamSetting; %'default';

import TIPEQK.*
TIP_time = TIPEQK.parameter.TimeTag('Train',sort([trn_0;trn_1]),'Forecast',[max([trn_0,trn_1]) + days(1);data_end]);


% key date: 2006-11-15 earliest record; 2012-02 PT stopped; 2014-03 CS started; 2015-11 MS started; around 2018-02 CS, MS, LY, YH failed.  
Rc_non_GEMSTIP = 50; %km
date0_str = '19000101'; % For plot only. Redirect to dt0 and dt1.
date1_str='20330724';% date0_str = '20100101'; date1_str='20190101';
dt0 = datetime(date0_str,'InputFormat','yyyyMMdd');
dt1 = datetime(date1_str,'InputFormat','yyyyMMdd');

% MolchanScore_load settings
BestN = 10;
nModels_Comb = 500;
match_trn_as_names = '(?<tag_0>\d{8})-(?<tag_1>\d{8})';
match_trn = '(?<=trn\[).+?(?=\])';


TwLatLim = [21.5 26]; TwLonLim = [118 122.5]; % Region of taiwan
ConsiderDepth = 1; % consider depth while looking for Earthquakes within Rc.
prefix_u = 'ULthr';
Res1 = '-r200';
errorStruct.identifier = 'Custom:Error';
errorStruct.message = 'No message';

switch PredParamSetting
    case 'default'
        PredParam = gen_Param('OutputFormat','table',...
            'Athr',[1:1:10],'Rc',[20:10:100],'Nthr',[1:1:2],...
            'Ptthr',[0.1:0.1:0.5],'Tobs',[5:5:100],'Tpred',[1],...
            'Tlead',[0:5:100],'Mc',5);%order is not important
    case 'test'
        PredParam = gen_Param('OutputFormat','table',...
            'Athr',2,'Rc',50,'Nthr',[1:1:2],...
            'Ptthr',[0.1:0.1:0.5],'Tobs',[5:5:100],'Tpred',[1],...
            'Tlead',[0:5:100],'Mc',5);%order is not important 
end
                            
Athr_list = unique(PredParam.Athr);

switch SKMVtype
    case 'ULF-C' % previous 'VLF'
        freqRange = [0.001 0.1]; freqRangeTag = 'ULF-C'; % introduction in chapter 5.
        SKMVtype = 'filtered';
    case 'ULF-B' % previous 'VLF'
        freqRange = [0.001 0.01]; freqRangeTag = 'ULF-B'; % introduction in chapter 5.
        SKMVtype = 'filtered';
    case 'ULF-A' % previous 'ULF'
        freqRange = [0.001 0.003]; freqRangeTag = 'ULF-A';
        SKMVtype = 'filtered';
    otherwise
        if ~strcmp(SKMVtype,'not filtered')
            error("Invalid 'SKMVtype'");
        end
        
end

switch SKMVtype
    case 'not filtered'
        GMPoD_Opt = {};
    case 'filtered' %Detrend and BandPass filter
        SKMVtype = [SKMVtype,'_',freqRangeTag];
        
        filteredFolderNm = ['FilteredData_',freqRangeTag,'_', datestr(now,'yyyymmdd')];  
        GMPoD_Opt = {'BandPass',freqRange,...
            'SaveFilteredData',filteredFolderNm,'RemoveOutliers',1};
        
        % If the filter range is fixed, there might be a function/method to out put
        % the filter function that it is not required to repeated the bandpass every time
        % the same filter function is used. This may increase speed.

        fprintf('SKMV type: filtered, range: %s.\n',freqRangeTag);
    otherwise
       errorStruct.message = ["SKMV_gen_type can only be",...
           "'not filtered' or 'filtered'. To specifying filter range,",...
           " please go to SOP_2019.m"];
       error(errorStruct);
end



% configurations
I.dataset = dataset_i;
I.tag_filter_range = SKMVtype;
I.tag_train_range = TIP_time.tag_train; % TagTrainRange;
I.tag_forecast_range = TIP_time.tag_forecast; % TagForcRange;
I.do_mkdir = true;
configs = config_cwb(I);
pf_iters = configs.numcores;
% % file paths and folder directories
% dataDir0 = configs.dir_data;
% dataDir = configs.dir_dataderived;
% save_PredParam = dataDir; % not used now. because gen_Param is fast.
% mapDir = configs.dir_map;
% scirptDir = configs.dir_script;
% catalog_path = configs.path_catalog;
% dir_molchan_train = configs.dir_molchan_train;
% dir_molchan_test = configs.dir_molchan_test;
% dir_tsAIN = configs.dir_tsAIN;
% savefig2 = configs.dir_save_figures;
% SKMVDir0 = configs.path_skewness_kurtosis;
% SKMVDir_tmp = configs.path_skewness_kurtosis_tmp;
% GMPoD_FilePath = configs.dir_processed_data_current;
% stationlocationPath = configs.path_station_location;
% probDir = configs.dir_EQK_probability; 
% JStDir = configs.dir_joint_station_summary; 
% JstVarDir = configs.dir_joint_station_vars; 
% JstVarPDir = configs.dir_joint_station_vars_prb;
% JstVarMDir = configs.dir_joint_station_vars_mol;

% Load map
shpFile = datalist('*.shp',configs.dir_map);
shpFile = shpFile.fullpath{1};


% Load stations
StationLocation_tb = load(configs.path_station_location);
StationLocation_tb = StationLocation_tb.StationLocation_tb;
StNames = StationLocation_tb.Properties.RowNames;
LatLons = struct(); % Station Location saved in structure for convenience.
for j = 1:size(StationLocation_tb,1)
    StNm = StationLocation_tb.Row{j};
    LatLons.(StNm) = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
end


% Load catalog
CWBcatalog = loadSheet(configs.path_catalog,'CWBcatalog2019');
CWBcatalogM5 = EQinRange(CWBcatalog,'TimeRange',[date0_str,' to ',date1_str],'Magnitude',5);

% colors and other settings
customgreen = [0, 0.5, 0];

% datetime information
fprintf('Time range of SKMV generation: \n         %s to %s \n',...
    date0_str,date1_str);
fprintf('Time range of catalog:\n         %s to %s \n',...
    datestr(CWBcatalog.DateTime(end)),datestr(CWBcatalog.DateTime(1)));
fprintf('GM data type: %s \n',SKMVtype);
%% Generate SKMV 1
% diaryFile = fullfile(configs.dir_dataderived,sprintf('Diary_SKMV_%s.txt',datestr(now,'yyyymmdd')));
% diary(diaryFile);

if settings_cwb.do_GMPoD && validpath(configs.dir_processed_data_current)
    % if its not a valid path, this section can't be executed.   
    [ SKMV ] = GMPoD(date0_str,date1_str,'FilePath',configs.dir_processed_data_current,...
        'TemporaryFile',configs.path_skewness_kurtosis_tmp,GMPoD_Opt{:});
    save(configs.path_skewness_kurtosis,'SKMV');
end
% diary off
%% Load 1 
varNmsAll = {'S','K','mu','V'};
SKMV = only1field(configs.path_skewness_kurtosis);
StNms = fieldnames(SKMV);

fprintf("'%s' loaded.\n",configs.path_skewness_kurtosis);

SKMV_rm = SKMV;
%  outlier removal
for i = 1:numel(StNms)
    StNm = StNames{i};
    for k = 1:numel(varNmsAll)
        varNm = varNmsAll{k};
        rm_idx = isoutlier(SKMV_rm.(StNm).(varNm));
        SKMV_rm.(StNm).(varNm)(rm_idx) = NaN;
    end
end
%(default)outlier is a value that is more than three scaled median absolute deviations (MAD) away from the median.
% MAD = median(abs(A_i-median(A)))
% The scaled MAD is defined as c*median(abs(A-median(A))) where c=-1/(sqrt(2)*erfcinv(3/2)).
% TF = isoutlier(Yk,'mean'); %Define outliers as points more than three standard deviations from the mean


[~,idx2plot] = ismember(varNms,SKMV.MS.Properties.VariableNames);
% idx2plot = [2,3]; % 2: skewness; 3: Kurtosis; 4: Mean; 5: Variance

%% Plot Timeseries as examples
if settings_cwb.do_Plot%warninginput('Message','[Plot Timeseries as examples] Do you want to plot?')
    ToPlot = {'ULF-A','ULF-B','ULF-C','not filtered'};
    Rthr = 50;
    Mthr = 6;
    sbn = 2;
    Nod = 2;
    Fs = 1; % (Hz) sampling frequency
    FolderList = table;
    TSOA_folder = fullfile(configs.dir_save_figures,'TimeSeriesOfADay_realtime'); mkdir(TSOA_folder);
    for tp = 1:length(ToPlot)
        FolderList_tp = datalist(sprintf('*%s*',ToPlot{tp}),fileparts(configs.dir_processed_data_current));
        FolderList = [FolderList;FolderList_tp];
    end
    sbm = size(FolderList,1);
    for j = 1:numel(StNames)
        StNm = StNames{j};
        CWBj = EQinRange(CWBcatalogM5,'Magnitude',Mthr,'Radius',{LatLons.(StNm),Rthr});
        
        DT = dateshift(CWBj.DateTime,'start','day');
        NoF = numel(DT);
        datadays = cell(Nod,1);
        for k = 1:NoF
            CWBjk = CWBj(k,:);
            for nd = 1:Nod
                datadays{nd} = datestr(CWBjk.DateTime-days(nd-1),'yyyymmdd');
            end
            datadays = flipud(datadays);
            figure;
            plt = 1;
            sb = gobjects(sbm,1);
            Yf = cell(1,sbm);
            tltYf = cell(1,sbm);
            Ytc = cell(1,sbm);
            Xtc = cell(1,sbm);
            LoS = NaN(sbm,1); % length of signal
            for FL = 1:sbm % time-strength plot
                TsFolder = FolderList.fullpath{FL};
                Ts_List = table;
                for nd = 1:Nod
                    Ts_List_tmp = datalist(sprintf('[%s]%s*',StNm,datadays{nd}),TsFolder,'Search','**');
                    Ts_List = [Ts_List;Ts_List_tmp];
                end
                if isempty(Ts_List)
                    continue % not every filtered folder has the time series
                end
                sb(plt) = subplot(sbm,sbn,2*FL-1); plt = plt + 1;
                YMDHmS_Yt = longSignal(Ts_List,'Column',[1:7]);
                Yt = YMDHmS_Yt{7};
                X_datetime = datetime(YMDHmS_Yt{1:6});
                plot(X_datetime,Yt);
                titlestr = FolderList.file{FL};
                title(titlestr,'Interpreter','none');
                
                Xtc(FL) = {X_datetime};
                Ytc(FL) = {Yt};
                Yf(FL) = {fft(Yt)};
                tltYf(FL) = {titlestr};
                LoS(FL) = length(Yt);
            end

            if plt>1
                subplot(sbm,sbn,[2:sbn:sbm*sbn]);
                vLinePlot(CWBjk.DateTime,sb,'CommonProperties',{'Color','r'},'LineProperties',{'LineWidth',1.5});
                mapplot('Options',{'LineWidth',0.5});%,'LatLim',TwLatLim,'LonLim',TwLonLim);
                axis equal
                xlabel('Longitude'); ylabel('Latitude');
                xlim(TwLonLim);  ylim(TwLatLim);
                title(sprintf('Station: %s',StNm));
                EQinRange(CWBjk,'PlotEpicenter',{'regular','monocolor','filled','MarkerEdgeColor','b'});
                plot(StationLocation_tb{StNm,'Lon'},StationLocation_tb{StNm,'Lat'},'b^','MarkerSize',8, 'MarkerFaceColor','b');
                set(gcf,'Position',[100,100,740,440]);
                fnm = sprintf('TimeSeriesOfADay[%s](%.3d).png',StNm,k);
                EQKinfo= sprintf('地震時間: %s \n 規模: %.1f; 經度: %.2f; 緯度: %.2f; 深度: %.1f km',...
                    datestr(CWBjk.DateTime),CWBjk.Mag,CWBjk.Lon,CWBjk.Lat,CWBjk.Depth);
                lazy_annotation(gcf,EQKinfo,'Position',[0.5,0.9]);
                print(fullfile(TSOA_folder,fnm),'-dpng','-r300');
                close;
            else
                close;
                continue
            end
            figure;
            flim = [0,0.02];
            alim = [0,0.1];
            for FL = 1:sbm % frequency-amplitude plot
                sbtmp1 = subplot(sbm,2,2*FL);
                L = LoS(FL);
                P2 = abs(Yf{FL}/L);
                P1 = P2(1:L/2+1);
                P1(2:end-1) = 2*P1(2:end-1);
                freq =  Fs*(0:(L/2))/L;
                plot(freq,P1);
                title(tltYf{FL},'Interpreter','none');
                xlabel('frequency (Hz)');
                ylabel('amplitude spectrum');
                xlim(flim);
                ylim(alim);
                sbtmp1.XTick = [flim(1), 0.003, 0.01, flim(end)];%flim(1):0.001:flim(end);
                sbtmp1.XTickLabelRotation = 45;
                
                sbtmp2 = subplot(sbm,2,2*FL-1);
                plot(Xtc{FL},Ytc{FL});
                title(tltYf{FL},'Interpreter','none');
            end
            sgtitle(sprintf('Geomagnetic record (station: %s)',StNm));
            adjPlot('larger');
            set(gcf,'Position',[200,200,850,700]);
            fnm = sprintf('FFT_TimeSeriesOfADay[%s](%.3d).png',StNm,k);
            print(fullfile(TSOA_folder,fnm),'-dpng','-r300');
            close;
        end
    end
%     GMPoD('20100101','20100102','FilePath',,'RemoveOutliers',1);
winopen_alt(TSOA_folder);
end



%% Map
if settings_cwb.do_Plot
    % Station Location

    % tagm = cellfun(@(nm,long,lati) sprintf('%s [%.1f,%.1f]',nm,long,lati) ,...
    %                     StNames,num2cell(StationLocation_tb.Lon),num2cell(StationLocation_tb.Lat),'UniformOutput',false);
    tagm = StNames;


    % lessthan5 = CWBcatalog.Mag<=5;
    % CWBcatalogM5_0 = CWBcatalog;
    % CWBcatalogM5_0(lessthan5,:) = [];
    % StationLocation_tb = matfile(fullfile(pwd,'GM_station_info','StationLocation_tb.mat'));


    Re = 6371; %radius of earth
    
    Rl = @(lat) Re*cosd(lat); % approx. radius for latitude of taiwan.

    % If high accuracy is required, check 'Radius at Geocentric Latitude' and 
    % 'Estimate radius of ellipsoid planet at geocentric latitude'
    % https://www.mathworks.com/help/aeroblks/radiusatgeocentriclatitude.html
    expd = 1.15; %expanding factor.


    fsubmap = figure;
    for i = 1:size(StationLocation_tb,1)
        StLon = StationLocation_tb.Lon(i);
        StLat = StationLocation_tb.Lat(i);
        Rc2lat = 360*Rc_non_GEMSTIP/(2*pi*Rl(StLat));
        Rc2lon = 360*Rc_non_GEMSTIP/(2*pi*Re);

        sb(i) = subplot(3,5,i);
        LatLim_sb = [StLat-Rc2lat*expd,StLat+Rc2lat*expd];
        LonLim_sb = [StLon-Rc2lon*expd,StLon+Rc2lon*expd];
    %     LatLon_sb{i} = 
        axm = worldmap(LatLim_sb,LonLim_sb);
    %     axesm('MapProjection','mercator','MapLatLimit',LatLim_sb,'MapLonLimit',LonLim_sb);
        geoshow(axm,shpFile,'FaceColor','white');
        plotm(StLat,StLon,'b^','MarkerSize',5, 'MarkerFaceColor','b');
        circlem(StLat,StLon,Rc_non_GEMSTIP,'edgecolor','b','edgealpha',0.3);
        title(sprintf('%s(%s)',StationLocation_tb.format{i},StationLocation_tb.Properties.RowNames{i}));
    end
    set(gcf,'Position',[10,10,1388,900]);



    fMap = figure;
    % shp = shaperead(shpFile);
    % mapshow(shp)% Display map data without projection               

    axm = worldmap(TwLatLim,TwLonLim);
    % axesm('MapProjection','mercator','MapLatLimit',LatLim,'MapLonLimit',LonLim);
    geoshow(axm,shpFile,'FaceColor','white');




    % Earthquakes in interest
    clr = flipud(hot);
    clr(1:90,:) = []; % remove those too bright in the color bar.
    clr(end-80:end,:) = []; 
    
    trn = '20081114-20151115';
    frc =  '20151116-20190415';
    frcstarclr = '#0af82f';
    mksize = [12,8];
    trnEvtM5 = eventFilter(CWBcatalogM5,'TimeRange',str2duration(trn).datetime);
    plotEpicenter(trnEvtM5,'filled','map','colormap',clr,'MarkerSize',mksize);
%     EQinRange(CWBcatalogM5,'PlotEpicenter',{'filled','MarkerFaceColor',clr},'TimeRange',str2duration(trn).datetime);    
    frcEvtM5 = eventFilter(CWBcatalogM5,'TimeRange',str2duration(frc).datetime);
    sct = plotEpicenter(frcEvtM5,'map','LineWidth',1.3,'Color','k','MarkerSize',mksize);
    sct.Children.MarkerEdgeAlpha = 0.4;
    sct.Children.MarkerEdgeColor = frcstarclr; % 'Color','#0af82f' will raise error.
%     EQinRange(CWBcatalogM5,'PlotEpicenter',...
%         {'MarkerFaceColor',clr,'LineWidth',1.3},...
%         'TimeRange',str2duration(frc).datetime);
  
    clrbar = colorbar;
    clrbar.Title.String = 'M_L';
    
    % plot location of station and default radius of detection (Rc=50).
    plotm(StationLocation_tb.Lat,StationLocation_tb.Lon,'b^','MarkerSize',4, 'MarkerFaceColor','b');
    textm(StationLocation_tb.Lat+0.03,StationLocation_tb.Lon+0.05,tagm,...
        'FontSize',10,'FontWeight','bold','Color','k');
%     txt_w = {'HL'}; % station names with white text
%     textm(StationLocation_tb{txt_w,'Lat'}+0.03,StationLocation_tb{txt_w,'Lon'}+0.055,txt_w,...
%         'FontSize',11,'FontWeight','bold','Color','w');
%     circlem(StationLocation_tb.Lat,StationLocation_tb.Lon,Rc_non_GEMSTIP,'edgecolor','b','edgealpha',0.3);
    
    legend_cell = {'earthquakes in training phase', 'earthquakes in forecasting phase','station'};
    plot_option = {
        {'p','MarkerSize',10,'MarkerFaceColor',clr(end,:),'Color','none'},...
        {'p','Color',frcstarclr,'MarkerSize',10},...
        {'^','Color','b','MarkerSize',6,'MarkerFaceColor','b'}
        };
    [H,plt] = superLegend(legend_cell,plot_option,'IsMarker',1,'LineLength',0.1,...
        'AxesPosition',[ 0.03    0.73    0.5    0.13]);
    set(gcf,'Position',[0,0,530,460]);

    print(fullfile(configs.dir_save_figures,'stationmap2.png'),'-dpng',Res1);

    winopen_alt(configs.dir_save_figures);


    % clrbar.Title.Rotation = -90; % clrbar.Title.Position = [32,115,0];
    % clrbar.Position = [0.94    0.12    0.01    0.8]; % adjust color bar [xstart, ystart, width, height]

end % Map


%% Test EQinRange with Rc centered at LatLon_j, St_j.
if settings_cwb.do_Plot
    
    for j = 1:length(StNames)
    Stj = StNames{j};
    
    figure;
    % shp = shaperead(shpFile);
    % mapshow(shp)% Display map data without projection               

    axm = worldmap(TwLatLim,TwLonLim);
    % axesm('MapProjection','mercator','MapLatLimit',LatLim,'MapLonLimit',LonLim);
    geoshow(axm,shpFile,'FaceColor','white');

    % plot location of station and default radius of detection (Rc=50).
    plotm(StationLocation_tb.Lat,StationLocation_tb.Lon,'b^','MarkerSize',7, 'MarkerFaceColor','b');
    circlem(StationLocation_tb.Lat,StationLocation_tb.Lon,Rc_non_GEMSTIP,'edgecolor','b','edgealpha',0.3);
    
    LatLon_j = [StationLocation_tb{Stj,'Lat'},StationLocation_tb{Stj,'Lon'}];
    EQinRange(CWBcatalogM5,'Radius',{LatLon_j,Rc_non_GEMSTIP},'PlotEpicenter',{'filled'},'TimeRange',[dt0,dt1]);
    textm(StationLocation_tb.Lat+0.03,StationLocation_tb.Lon+0.05,...
        StationLocation_tb.Properties.RowNames,'FontSize',10,'FontWeight','bold');    
    title(sprintf('EQinRange: Station %s',Stj))
    clr = flipud(hot); clr(1:35,:) = []; % remove those too bright in the color bar.
    colormap(clr);
    set(gcf,'Position',[0,0,840,680]);
    close;
    end

end

%% Overall_Data_Availability
% path_d = fullfile(back_to(pwd,'1MyResearch'),'DATA','GM_DATA_derived','Set_2');
% path_d_SKMV = fullfile(path_d,'SKMV');
% SKMV_list = datalist_v2('*.mat',path_d_SKMV,'Search','**');
% SKMV_path = SKMV_list(:,4);
% % [~,NoSt] = GMStList('AllNames');
% NoSt = numel(SKMV_path);
% da_array = NaN(NoSt,NoD);
if settings_cwb.do_Plot
    typeOD = 'all';% 'MS_PT_KM';
    % typeOD = 'all';
    NoSt =numel(StNms);
    switch typeOD
        case 'all'
            range1 = 1:NoSt; 
            figPos1 = [0,0,1068,412];
            titlePos = [32,115,0];
        case 'MS_PT_KM'
            range1 = [13,6,11]; %1:NoSt
            figPos1 = [0,0,1068,280];
            titlePos = [32,90,0];
        otherwise
            error('Error at Overall Data Availability');
    end


    dQ_array=[];
    % St_Names = cell(NoSt,1);
    NoStTmp = length(range1);
    StTmp = cell(NoStTmp,1);
    da_array = [];
    k = 1;
    for i = range1
    %     Si(i) = only1field(SKMV_path{i});
        St = StNms{i};
        availableDataRatio = 1-SKMV.(St).BDoD';
        availableDataRatio(availableDataRatio<0.001) =0;
        da_array(k,:) = availableDataRatio;
        StTmp{k} = St; k=k+1;
    %     da_array(i,:) = cell2mat(Si(i).GMPs.data_availability)';
    %     da_array(i,:) = [Si(i).GMPs.data_availability]'; % change to this after regenerate SKMV
    %     dQ_array(i,:) = [Si(i).GMPs.mean_Q]';

    end

    DateTime = SKMV.TW.DateTime;
    NoD = numel(DateTime); % number of Days (total)

    % da0idx = find(da_array==0|isnan(da_array));
    % dQOrNaNidx = find(isnan(dQ_array)|dQ_array==0);
    % if isequal(da0idx,dQOrNaNidx)
    %     disp('data_availability==0 is exactly dQ_mean ==0 or NaN');
    %     disp('It is OK to use dQ_mean only, da_array is not required. ');
    %     % by the way, NaN correspond to the same color as 0 in imagesc.
    % else
    %     warning('something wrong, please check isequal(da0idx,dQOrNaNidx)\n')
    % end


    % Plot 
    f1 = figure;
    y0 = linspace(1,NoStTmp,NoStTmp);
    y_ticks = [1:NoStTmp];
    [ticks1,tickLabels,x0] = datetime_ticks(DateTime,'yyyy-mm',3,'Months');% x = datenum(DateTime);
    % [ticks,tickLabels] = datetime_ticks(t3,'yy/mm/dd',5,'days');
    % set(ax1(end),'XTickLabel',tickLabels,'XTick',ticks);



    imagesc(x0,y0,da_array);% datetick('x','yyyy-mmm','keepticks');
    gca1= gca;
    set(gca1,'YTickLabel',StTmp,'YTick',y_ticks);
    set(gca1,'XTickLabel',tickLabels,'XTick',datenum(ticks1));
    xtickangle(45);
    % datetick('x','yyyy-mmm','keepticks');

    A = flipud(cool); % flip color array 'cool' (or 'jet', 'winter'...) up-side-down.
    title('Overall data availability');
    % A = winter;
    A(1,:) = [1,1,1];
    colormap(A);
    f1.Position = figPos1;

    clrbar = colorbar;
    clrbar.Title.String = 'Percentage of available data points (0-1]';
    clrbar.Title.Rotation = -90;
    clrbar.Title.Position = titlePos;
    clrbar.Position = [0.94    0.12    0.01    0.8]; % adjust color bar [xstart, ystart, width, height]

    dupAx(gca1);
    print(fullfile(configs.dir_save_figures,sprintf('OveralldataAvailability_(%s).png',typeOD)),'-dpng','-r300');
    winopen_alt(configs.dir_save_figures);
end

% %% Plot SKMV and Earthquakes events
% % addpath(back_to(pwd,'MATLAB','add-on','subtightplot'));
% % % addpath(back_to(pwd,'MATLAB','add-on','csvimport')); % for EQinRC
% % % addpath(back_to(pwd,'MATLAB','add-on','lldistkm')); % for EQinRC
% 
% if warninginput
%     print_to = fullfile(pwd,'fig4png');
%     NoSKMVp = numel(StNms);
% 
%     try
%         StNm = StNms{i};
%         ax = Fig_4(SKMV,StationLocation_tb,CWBcatalogM5,Rc);
% %         dtRange = ax.XLim;
% %         desiredRange = CWBcatalogM5.DateTime > dtRange(1) & CWBcatalogM5.DateTime < dtRange(2);
% %         CWBcatalog1 = CWBcatalogM5(desiredRange,:); % desired time range
% %         StNm = SKMV(i).St; disp(StNm);
% 
% 
% %         png_i = sprintf('[%s] Rc=%d',StNm,Rc);
% %         print(fullfile(print_to,png_i),'-dpng','-r200');
% %         close;
%     catch ME
%         if strcmp(ME.identifier,'MATLAB:table:UnrecognizedRowName')
%             warning('Information for Station %s do not exist in the table.',StNm);
%         else
%             rethrow(ME);
%         end
%     end
% 
% end% if warninginput
%% PDF of the parameter SKMV
if settings_cwb.do_Plot
    fname = sprintf('PDFofParameters_%s',SKMVtype);
    savefig2_pdfParam = fullfile(configs.dir_save_figures,fname);
    validpath(savefig2_pdfParam,'mkdir');
    
    for i = 1: numel(StNms)
        StNm = StNms{i};
        figure;
        tb1 = SKMV_rm.(StNm);
        tb2 = tb1;
        colNms = tb2.Properties.VariableNames;
        for k = 2:5        
            subplot(2,2,k-1);
            Yk = tb2{:,colNms{k}};
%             Yk = Yk(~isnan(Yk)); % revoce NaN
%             % Remove Outliers
%             TF = isoutlier(Yk,'mean');
%             Yk = Yk(TF);
            % isoutlier(Yk,'mean'); %Define outliers as points more than three standard deviations from the mean

            [fk, xk] = ksdensity(Yk);
            plot(xk,fk);
            % histogram(tb1{:,colNms{k}});
            title(sprintf('pdf of %s',colNms{k}));
            xlabel(colNms{k});
            ylabel(sprintf('pdf(%s)',colNms{k}))
        end
        StChNms = StationLocation_tb{StNm,'format'};
        sgtitle(sprintf('%s (%s)',StChNms{1},StNm));
        % lazy_annotation(gcf,'outlier removed','Position',[0.89,0.005]);
        adjPlot('set1');
        set(gcf,'Position',[50,50,700,450]);
        print(fullfile(savefig2_pdfParam,sprintf('[%s]%s',StNm,fname)),'-dpng',Res1);
        close;
    end
end% if warninginput
%% PDF of the parameter SK and their Q-Q plot

S_CI95_e = struct();

if settings_cwb.do_Plot
dt11 = datetime('19990801','InputFormat','yyyyMMdd');
dt22 = datetime('20200101','InputFormat','yyyyMMdd');
fname = sprintf('PDFandQQPlot(%s)',SKMVtype);
savefig2_SKQQPlt = fullfile(configs.dir_save_figures,fname);
validpath(savefig2_SKQQPlt,'mkdir');
    for i = 1: numel(StNms)
        StNm = StNms{i};

        figure;
        sbm = length(idx2plot);   sbn = 2; 
        tb1 = SKMV_rm.(StNm); % outlier removed.
%         tb1 = SKMV.(StNm);
        idx11 = find(tb1.DateTime >= dt11, 1, 'first' );
        idx22 = find(tb1.DateTime <= dt22, 1, 'last' );
        S_CI95_e.(StNm).DateTimeRange = [tb1.DateTime(idx11);tb1.DateTime(idx22)];
        tb2 = tb1;
    %     tb2 = tb1(1:idx11,:);
    %     tb2 = tb1(idx22:end,:);
        colNms = tb2.Properties.VariableNames;
        
        pltat = 1;
        for k =  idx2plot% pdf
            
            Yk = tb2{:,colNms{k}};

            mu = nanmean(Yk);
            sigma = nanstd(Yk);

            CI95qt = [0.025,0.975]; %quantile for 95% confidence interval
            CI95n = norminv(CI95qt,mu,sigma);
            CI95E = CIxxE(Yk);
            S_CI95_e.(StNm).(['CI95_',colNms{k}]) = CI95E;
            
            
                subplot(sbm,sbn,pltat); %plot pdf
                pltat = pltat+1;
                dof = length(Yk)-1;
    %             CI95t = tinv(CI95qt,dof);
                CI95e = CIxxE(Yk,'ConfidenceInterval',CI95qt);
                [fk, xk] = ksdensity(Yk);
                fkn = normpdf(xk,mu,sigma);
                plot(xk,fk);
                hold on
                plot(xk,fkn);        %         histogram(tb1{:,colNms{k}});
%                 vLinePlot(CI95n,gca,'CommonProperties',{'Color','b'},'text','CI95n','TextShift',[0,-0.08]);
    %             vLinePlot(CI95t,gca,'CommonProperties',{'Color','r'},'text','CI95t');
                vLinePlot(CI95e,gca,'CommonProperties',{'Color',customgreen},'text','CI95e','TextShift',[0,-0.15]);
                title(sprintf('pdf of %s',colNms{k}));
                legend({'pdf of data','normal distrib.'});
                xlabel(colNms{k});                 ylabel(sprintf('pdf(%s)',colNms{k}))

                subplot(sbm,sbn,pltat); % Q-Q plot
                pltat = pltat+1;
                qqPlot(Yk,'Normal',{mu,sigma},'Title',sprintf('Q-Q plot of %s',colNms{k}));
        %         subplot(sbm,sbn,k+3); qqplot(Yk_no_outlier);
                StChNms = StationLocation_tb{StNm,'format'};
                sgtitle(sprintf('%s (%s)',StChNms{1},StNm));
                set(gcf,'Position',[50,50,940,620]);
                
                set(findobj(gcf,'type','legend'),'Position',[0.08,0.47,0.15,0.05]);
%                 lazy_annotation(gcf,'outlier removed','Position',[0.89,0.003],'FontSize',10);

            

        end
%                 adjPlot('set1_1');
                adjPlot('larger','thicker')
                print(fullfile(savefig2_SKQQPlt,sprintf('[%s]%s',StNm,fname)),'-dpng',Res1);
                close;


    end
    
end
    
%% Case study setting
MthrCase_M = 6;
% idx_to_plot = [2,3]; % indicating variables (Skewness, Kurtosis,...) to plot.\
prefix = 'AIN_';
suffix = 'mean';
nanThr = 60; %  nan in S OR K > nanThr, then skip the window/loop

% valNms = SKMV_rm.(StNames{1}).Properties.VariableNames(idx_to_plot);
% valNms must be defined preceeded to @(x) [prefix,valNms{x}];
colNm_var = @(x) [prefix,varNms{x}];
colNm_var1 = @(x) [prefix,varNms{x},'_',suffix];
CWBcatalog1 = EQinRange(CWBcatalog,'TimeRange',[dt0,dt1],'Magnitude',MthrCase_M);   
[mmm,~] = size(CWBcatalog1);


%% (Case Study) Zoomed view around desired Earthquakes
% To do (1): build a function of CWBcatalog2 input and t_tag range/idx out.
% (2) for those t_tag ranges, plot time series (t_tag, Y) in the range and vLinePlot.
% Run Section "Load full SKMV structure" first to load full SKMV.

if settings_cwb.do_Plot % case study
figzDir = fullfile(configs.dir_save_figures,['zoom_around_events_',SKMVtype]);
validpath(figzDir,'mkdir');
gap = [0.05 0.05]; %[vertical spacing, horizontal spacing]
marg_h = [0.1 0.1]; %[bottom edge, top edge]
marg_w = [0.1 0.01];%[left edge, right edge]



varNmsTb = [{'Station'},{'DateTime'},...
    cellfun(@(x)[prefix,x],varNms,'UniformOutput',false),[prefix,'sum'],{'info'}];
NoC1 = length(varNmsTb);
varTypTb = cell(1,NoC1);
varTypTb(:) = {'doublenan'}; varTypTb([1,end]) = {'cell'};
varTypTb(2) = {'datetime'};
AINtbEvt = table('Size',[3*mmm,NoC1],'VariableTypes',varTypTb,...
                                                           'VariableNames',varNmsTb);% create a table large enough
kkk = 1;

%     lgd_list = {'Mean','Variance','Skewness','Kurtosis'};
%     YLbl_list = {'\mu','V','S','K'};
    CaseStudyCatalog = CWBcatalog1;
    CaseStudyCatalog(:,:) = [];
    NotCaseStudyCatalog = CaseStudyCatalog;
%     NotCaseStation = {};


    for i = 1:numel(StNames)
    StNm = StNames{i};
%     GMPs = SKMV.(StNm);
    GMPs = SKMV_rm.(StNm);
    LatLon_i = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
    CWBcatalog2 = EQinRange(CWBcatalog1,'Radius',{LatLon_i,Rc_non_GEMSTIP},'ConsiderDepth',ConsiderDepth,...
        'TimeRange',[SKMV_rm.(StNm).DateTime(1), SKMV_rm.(StNm).DateTime(end)]);
    [NoRj,~] = size(CWBcatalog2);
    fig = gobjects(NoRj,1);
    
        for j= 1:NoRj
            DateTime_j = CWBcatalog2.DateTime(j);
            M_j = CWBcatalog2.Mag(j);
            event_j = CWBcatalog2(j,:);
            
            datestr_j = datestr(DateTime_j,'yyyymmdd');
            if abs(DateTime_j - CWBcatalog2.DateTime(max([1,j-1]))) <days(1) && M_j < CWBcatalog2.Mag(max([1,j-1]))
                continue % if events are too close, one figure is enough.
            end
            dtt0 = DateTime_j - days(80);
            dtt1 = DateTime_j +days(20);

            idxi = GMPs.DateTime > dtt0  &GMPs.DateTime < dtt1;
            Tbi = GMPs(idxi,:);
            t3 = Tbi.DateTime;
            
            Tbk = Tbi(:,idx2plot);
            NoCk = numel(idx2plot);
            varNms = Tbk.Properties.VariableNames;
            
            NNaN = sum(isnan(Tbk{:,:}));
            if NNaN(1)>nanThr||NNaN(2)>nanThr%all(isnan(Tbk{:,:}))
                NotCaseStudyCatalog = [NotCaseStudyCatalog;event_j];
%                 NotCaseStation = [NotCaseStation;StNm];   
                continue
            end
            
            CaseStudyCatalog = [CaseStudyCatalog ;event_j];% MUST be after 'if~continue~' statement
            if warninginput
                fig(j) = figure;
                set(fig(j),'defaultLegendAutoUpdate','off'); % to prevent automatically add 'data1', 'data2'....
            end%if warninginput
                AINSUM = 0;
                for k = 1:NoCk
                    y3 = Tbk{:,k};
                    CI95_j_k = S_CI95_e.(StNm).(['CI95_',varNms{k}]);
                   outCI95_k = sum(y3<CI95_j_k(1) | y3>CI95_j_k(2));
                   AINtbEvt.(colNm_var(k))(kkk) = outCI95_k; 
                   AINSUM = AINSUM + outCI95_k;
                   
                    if warninginput
                        ax1(k) = subtightplot(NoCk,2,2*k-1,gap,marg_h,marg_w);
                        plot(t3,y3,'-bo'); hold on
        %                 if all(isnan(y3))
        %                     lazytext('No data','Location','Center');
        %                 end
    %                     legend(valNms{k});  set(gca, 'xticklabel', []); %只消除tick的標籤，tick本身仍然留著。 
                        %set(gca,'xtick',[]); %連tick都沒有
                        ylabel(varNms{k});
        %                 ax1(k).YLabel.Rotation=0; % rotate YLabel to horizontal
                        set(ax1(k),'XLim',[t3(1),t3(end)]); % must preceed hLinePlot. This is required since NaN will not be plotted.
                        hLinePlot(CI95_j_k,'CommonProperties',{'Color',customgreen},'text','CI95');
                        set(ax1(k),'XTickLabel',[]);
                        if k ==1
                            Lat_j = CWBcatalog2.Lat(j);
                            Lon_j = CWBcatalog2.Lon(j);
                            dt_j = datestr(DateTime_j,'dd-mmm-yyyy');
                            uptitle = sprintf('Evt. time = %s; M_L = %.1f; LatLon = [%.2f,%.2f]',dt_j,M_j,Lat_j,Lon_j);
                            title(uptitle);
                        end
                        lazytext(sprintf('AIN=%d',outCI95_k),'Position',[0.94,1.05]);
                    end%if warninginput
                end
                AINtbEvt.DateTime(kkk) =DateTime_j;
                AINtbEvt.Station(kkk) = {StNm};
                AINtbEvt.([prefix,'sum'])(kkk) = AINSUM;
                kkk = kkk +1; % Must be after all 'if... continue...' 
                
            if warninginput
                [catalog_tmp] = EQinRange(CWBcatalog2,'PlotVerticalLine',ax1,...
                    'TimeRange',[dtt0, dtt1]);%'MagnitudeTag',{'Rotation',45}
                vLinePlot(DateTime_j,ax1,'CommonProperties',{'Color','r'});

                [ticks,tickLabels] = datetime_ticks(t3,'yy/mm/dd',5,'days');
                set(ax1(end),'XTickLabel',tickLabels,'XTick',ticks);

                xtickangle(45); %xtickformat('yy/MM/dd');       
    %             disp(['figure',num2str(j)])
    %             catalog_tmp
                ax_tmp = subtightplot(NoCk,2,[2,4],gap,marg_h,marg_w);
                copyPlot(sb(i),fig(j),'ToSubplot',ax_tmp);
                EQinRange(catalog_tmp,'PlotEpicenter',1);
                EQinRange(event_j,'PlotEpicenter',{'filled'});
                clrbar = colorbar;
                clrbar.Title.String = 'M_L';
        %         Ax1 = vLinePlot(event_j,ax1,'CommonProperties',{'Color','r'},'text',sprintf('M_L=%.1f',CWBcatalog2.Mag(j)));            



                set(gcf,'Position',[10,10,870,420]);
                adjPlot('set1');

                A = sprintf('Rc = %d; ',Rc_non_GEMSTIP);
    %             if size(catalog_tmp,1)>3
    %                 B = sprintf('%.1f; ',catalog_tmp.Depth(1:3));
    %                 B = [B,'...'];
    %             else 
    %                 B = sprintf('%.1f; ',catalog_tmp.Depth(:));
    %             end
                B = sprintf('%.1f ',catalog_tmp.Depth(1));
    %             lazy_annotation(gcf,[A,'Depth = ',B,' (',SKMVtype,')'],'Position',[0.08,0.48],'FontSize',10)
                lazy_annotation(gcf,[A,'D = ',B],'Position',[0.56,0.05],'FontSize',10);
                pngNm = sprintf('(%s)[%s]ZoomView(%.4d).png',datestr_j,StNm,j);
                print(fullfile(figzDir,pngNm),'-dpng',Res1);

                print2 = false;
                for k = 1:NoCk
                    CI95_k = S_CI95_e.(StNm).(['CI95_',varNms{k}]);
                    diffCI95_k = diff(CI95_k);
                    if diff(ax1(k).YLim) > 5*diffCI95_k %if the YLim ranges to much
                        set(ax1(k),'YLim',CI95_k + [-0.2*diffCI95_k, 0.2*diffCI95_k]); % then reduce YLim to extended CI95
                        print2 = true;
                    end               
                end

                if print2
                    pngNm2 = sprintf('(%s)[%s]ZoomView(%.4d_2).png',datestr_j,StNm,j);
                    print(fullfile(figzDir,pngNm2),'-dpng',Res1);
                end
                close;
            end%if warninginput
            
        end
    %     img = fig2im(fig{:});


    end

%     NotCaseStudyCatalog.Station = NotCaseStation;

% table2excel(CaseStudyCatalog);
AINtbEvt =AINtbEvt(1:kkk,:);

AINtbEvt = tableSum(AINtbEvt,'sum','mean');
table2excel(AINtbEvt);

end

%% (Case Study) Zoomed view of silent interval (w/ summary table)

if settings_cwb.do_Plot
figz2Dir = fullfile(configs.dir_save_figures,['zoom_no_event_',SKMVtype]);
validpath(figz2Dir,'mkdir');


NoSt = numel(StNames);
CaseStudyCatalog = CWBcatalog1;
CaseStudyCatalog(:,:) = [];
Denominator = 100;
dd = 100;
NoCk = numel(idx2plot);
AINtb = struct();
for i = 1:NoSt
    StNm = StNames{i};
%     GMPs = SKMV.(StNm);
    GMPs = SKMV_rm.(StNm);
    LatLon_i = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
    
    dtSt = GMPs.DateTime;
    dtSt = sort(dtSt);
    totalDays = days(dtSt(end)-dtSt(1));
%     rangeJ = 1:totalDays;
    dt0_j = dtSt(1);
    
%     CWBcatalog2 = EQinRange(CWBcatalog1,'Radius',{LatLon_i,Rc},'ConsiderDepth',ConsiderDepth);
%     EQDateTimeInRc = CWBcatalog2.DateTime;
    
    
    NoRR = ceil(totalDays/Denominator);
%     NoRR = totalDays;
    S_tmp = struct();
    S_tmp.dt0 = NaT(NoRR,1);
    S_tmp.dt1 = S_tmp.dt0;
    
    for k = 1:NoCk
        S_tmp.(colNm_var(k)) = NaN(NoRR,1);
    end
    
    AINtb.(StNm) = struct2table(S_tmp);
    AINtb.(StNm).([prefix,'sum']) = NaN(NoRR,1);
    AINtb.(StNm).info = cell(NoRR,1);
    
    for kk = 1:NoRR
% kk= 0;
%     while dt0_j + days(Denominator) < max(GMPs.DateTime)
%         kk = kk+1;
        idxi = GMPs.DateTime >= dt0_j & GMPs.DateTime < dt0_j + days(Denominator);
%         dt0_j = dt0_j + days(1);


        dt0_j = dt0_j + days(Denominator); %順利到最後一行，則跳下個百日
        Tbi = GMPs(idxi,:);        
        t3 = Tbi.DateTime;
        Tbk = Tbi(:,idx2plot);
        
        EQtb = EQinRange(CWBcatalog1,'Radius',{LatLon_i,Rc_non_GEMSTIP},'ConsiderDepth',ConsiderDepth,...
            'TimeRange',[t3(1) - days(dd),t3(end) + days(Denominator + dd)]);
        
        if ~isempty(EQtb)
            AINtb.(StNm).info{kk} = sprintf('EQ in %d days',dd);
            continue
        end
        
        
%         [~,~,dist1] = nearest1d(EQDateTimeInRc,[t3(1),t3(end)]);
%         dd = days(dist1)

        
        
        
        AINtb.(StNm).dt0(kk) = t3(1);
        AINtb.(StNm).dt1(kk) = t3(end);

        if warninginput

        end%if warninginput
        
        
%         if numel(dist1)==1
%             % if EQDateTimeInRc==1, then numel(dist1)==1
%             dist1 = [dist1,days(999)]; % to prevent error,could be fixed in the future.
%         end
        
        
        NNaN = sum(isnan(Tbk{:,:}));
        if NNaN(1)>nanThr||NNaN(2)>nanThr
            AINtb.(StNm).info{kk} = sprintf('>%d% NaN',nanThr);
            continue
        end
        
%         if ~isempty(dist1)
%             if dist1(1)<days(80) || dist1(2)<days(80)
%                 AINtb.(StNm).info{kk} = 'EQ in 80 days';
%                 continue
%             end
%         end
        
        



        AIN_sum = 0;
        for k = 1:NoCk
            y3 = Tbk{:,k};
            CI95_j_k = S_CI95_e.(StNm).(['CI95_',varNms{k}]);
            AINtb.(StNm).(colNm_var(k))(kk) = nansum(y3<CI95_j_k(1) | y3>CI95_j_k(2));
            AIN_sum = AIN_sum + AINtb.(StNm).(colNm_var(k))(kk);
        end
        AINtb.(StNm).([prefix,'sum'])(kk) = AIN_sum;
        
%         dt0_j = dt0_j + 99; %順利到最後一行，則跳下個百日
    end

end

Ftb = struct();
Ftb.Station = cell(NoSt,1);
for k = 1:NoCk
    Ftb.(colNm_var1(k)) = NaN(NoSt,1);
end
Ftb.([prefix,'all_',suffix]) = NaN(NoSt,1);
Ftb.total_Windows = NaN(NoSt,1);
Ftb = struct2table(Ftb);

for i = 1:NoSt
    StNm = StNames{i};
%     valNms = SKMV.(StNm).Properties.VariableNames(idx_to_plot);
    Ftb.Station{i} = StNm;
    Ftb.([prefix,'all_',suffix])(i)= nanmean(AINtb.(StNm).AIN_sum);
    for k = 1:NoCk
        Ftb.(colNm_var1(k))(i)= nanmean(AINtb.(StNm).(colNm_var(k)));
    end
    Ftb.total_Windows(i) = sum(~isnan(AINtb.(StNm).([prefix,'sum'])));
%     AINtb.(StNm)
end
Ftb.Properties.RowNames = Ftb.Station;
Ftb2 = tableSum(Ftb,'mean','sum');
table2excel(Ftb2); 

end
%% AINbase
if settings_cwb.do_AINbase
    if ~exist('SKMV','var')
        error('Run Section "Load full SKMV structure" first to load full SKMV.');
    end
    NoSKMV = numel(StNms);
    for mw = 1:numel(MvWin)

        tic; H = timeLeft0(NoSKMV,'SOP__2019: AINbase');
        for i = 1:NoSKMV
            [H] = timeLeft1(toc,i,H);
            StNm = StNms{i};
            tYtable = SKMV.(StNm)(:,1:3);
            tYtable.S = abs(tYtable.S);
            fprintf('AINbase: station %s.',StNm);
            [tsAIN,ULthr] = AINbase(tYtable,Athr_list,'MovingWindow',MvWin(mw));
    %         save([save_tsAIN filesep sprintf('[%s]tsAIN_MvWin=%d.mat',SKMV(i).St,MvWin(mw))],'tsAIN');
            save([configs.dir_tsAIN filesep sprintf('[%s]tsAIN_MvWin=%d.mat',StNm,MvWin(mw))],'tsAIN');
            save([configs.dir_tsAIN filesep sprintf('[%s]ULthr_MvWin=%d.mat',StNm,MvWin(mw))],'ULthr');
    %         figure; plot(SKMV(i).GMPs.DateTime,SKMV(i).GMPs.S);

        end
        delete(H.waitbarHandle);
    % tsAIN_files = datalist('*tsAIN*',save_tsAIN);
    % tsAIN = only1field(tsAIN_files.fullpath{1});

    end
end
%% Setting for Plot anomaly days and Skewness-Kurtosis-ULthr
FigPosAno = [10,10,900,300];

%% Plot Skewness, Kurtosis, and the threshold ULthr (Athr)

if settings_cwb.do_Plot

    if ~exist('FigPosAno','var')
       error("Go to 'Setting for Plot anomaly days and Skewness-Kurtosis-ULthr' first");
    end
    
    AthrList = [1:5];


    NoSb = length(idx2plot);

    keywd = sprintf('[*]%s*',prefix_u);
    ULthr_list = datalist(keywd,configs.dir_tsAIN);    
    dat15 = datetime('20150815','inputFormat','yyyyMMdd');
    folderNm = sprintf('Time Series With Athr (%s)',SKMVtype);
    TsWithAthrFolder = fullfile(configs.dir_save_figures,folderNm);
    mkdir(TsWithAthrFolder);
% for d = 1:2%length(timerange1)
    for k = 1:numel(ULthr_list.name)
        StNm = regexp(ULthr_list.name{k},'(?<=\[)[A-Z]{2}','match');
        StNm = only1field(StNm);
        GMPs = SKMV.(StNm);
        tg = GMPs.DateTime;
        GMPs_k = GMPs(:,idx2plot);
        ULthr_k = only1field(ULthr_list.fullpath{k}); 
        NoL = size(ULthr_k,1);
        LatLon = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
        CWBcatalogSt = EQinRange(CWBcatalog,'Magnitude',5,'TimeRange',[tg(1),tg(end)],'Radius',{LatLon,Rc_non_GEMSTIP});

        figure;    set(gcf,'defaultLegendAutoUpdate','off'); % to prevent automatically add 'data1', 'data2'....
        for i = 1:NoSb
            valNm = GMPs_k.Properties.VariableNames{i};
            yy = abs(GMPs_k.(valNm));
            subplot(NoSb,1,i)
            plot(tg,yy);
            hold on
            lgdcell = {valNm};
            for l = AthrList
                ULthr_l = ULthr_k.([prefix_u,'_',valNm]){l}(:,1);
                plot(ULthr_k.DateTime{1},ULthr_l);
                lgdcell = [lgdcell,{sprintf('Athr=%d',l)}];
            end
            legend(lgdcell,'Location','EastOutside');
            ylabel(valNm);
            if all(isnan(ULthr_l))
                gcaopt = {};
            else
                gcaopt = {'YLim',[0 max(ULthr_l)*2]};
            end
            set(gca,gcaopt{:});

            ax(i) = gca;
            
%             [ticks,tickLabels] = datetime_ticks(tg,'yy/mm/dd',4,'days');
%             set(gca,'XTickLabel',tickLabels,'XTick',ticks);
            
        end
        
        sgtitle(sprintf('Station: %s (%s)',StNm,SKMVtype));
%         EQinRange(CWBcatalogSt,'PlotVerticalLine',ax,'TimeRange',[tg(1),tg(end)]);
        catatmp = eventFilter(CWBcatalogSt,'TimeRange',[tg(1),tg(end)]);
        vLinePlot_EventTime(catatmp,ax,'TagValues','Mag');
        
        fnamekall = sprintf('[%s]TsWithAthr(%s).png',StNm,SKMVtype);
        set(gcf,'Position',FigPosAno);
        print(fullfile(TsWithAthrFolder,fnamekall),'-dpng',Res1);
        close;
%         dt0k = min(ULthr_k.DateTime{1});
%         dt1k = max(ULthr_k.DateTime{1});
%         PosX = 400;
%         PosY = 300;
%         TimeSec = [dt0k,dat15;dat17,dt1k];
%         diffTimeSec = diff(TimeSec,1,2);
%         PosFactor = diffTimeSec/min(diffTimeSec);
%             for d = 1:size(TimeSec,1)
%                 fnamek = sprintf('[%s]TsWithAthr(%s)_%d.png',StNm,SKMVtype,d);
%                 set(ax,'XLim',TimeSec(d,:));
%                 set(gcf,'Position',[0,0,round(PosX*PosFactor(d)),PosY]);
%                 EQinRange(CWBcatalogSt,'PlotVerticalLine',ax,'TimeRange',TimeSec(d,:));
%                 print(fullfile(TsWithAthrFolder,fnamek),'-dpng',Res1);

%             end
%         close;
        
    end
    winopen_alt(TsWithAthrFolder);
    
% end
end


%% Plot tsAIN (fig 7a)
% if warninginput
%     tsAIN_path = datalist('*tsAIN*',save_tsAIN);
%     NoFiles = numel(tsAIN_path.fullpath);
%     for i = 1:NoFiles
%     tsAIN_St = only1field(tsAIN_path.fullpath{i});
%     MvWin2 = regexp(tsAIN_path.name{i},'MvWin=\d+','match');
%     StNm = regexp(tsAIN_path.name{i},'\[[A-Z]+\]','match');
%     tsAINdt = tsAIN_St.DateTime{1};
%     
%     NoL = numel(tsAIN_St.Athr);
%     f = cell(1,NoL);
%         for ii= 1:NoL
%             f{ii} = figure;
%         %     bar(tsAIN_St(ii).DateNum,tsAIN_St(ii).tsAIN_K); %Fig.7(a)
%         %     hold on
%         %     bar(tsAIN_St(ii).DateNum,tsAIN_St(ii).tsAIN_S); %Fig.7(a)
%         %     legend({'Kurtosis','Skewness'})
%             [vars,fieldNams] = fieldsFind(tsAIN_St(ii,:),'tsAIN');
%             tsAIN_sum = sum(cell2mat(vars),2);
%             plot(tsAINdt,tsAIN_sum,'-ro');
%             title(sprintf('%s Sum of tsAIN with Athr = %.3f, %s',StNm{1},tsAIN_St.Athr(ii),MvWin2{1}));
% 
%         end
% 
%     imgs = fig2im(f{:});
%     close(f{:});
%     figure;
%     montage(imgs);
%     end
% end %if warninginput

%% Plot Anomaly index (fig(7b))

if settings_cwb.do_Plot
    dat15 = datetime('20150815','inputFormat','yyyyMMdd');
    dat17 = datetime('20170101','inputFormat','yyyyMMdd');
    AthrList =2:3;%[2:2:10];%NoL
    splitters = [dat15,dat17];
    figHeight = 300;
    Nthr = 1;
    folderNm = sprintf('Time Series of Anomaly Day (%s)',SKMVtype);
    figPath = fullfile(configs.dir_save_figures,folderNm);
    mkdir(figPath);
%     folderPath = back_to(pwd,0,folderNm);
    list_tsAIN_path = datalist('*tsAIN*',configs.dir_tsAIN);
    NoFiles = numel(list_tsAIN_path.fullpath);
    for i = 1:NoFiles
    tsAIN_St = only1field(list_tsAIN_path.fullpath{i});
%     MvWin2 = regexp(tsAIN_path.name{i},'MvWin=\d+','match','once');
    StNm = regexp(list_tsAIN_path.name{i},'(?<=\[)[A-Z]+','match','once');%前面是中括號才會匹配到，匹配到第一個就停止('once')
    tsAINdt = tsAIN_St.DateTime{1};
    Athr_i = tsAIN_St.Athr;
    NoL = numel(Athr_i);
    
    timeRange_i = [tsAINdt(1),tsAINdt(end)];
    
            figcell = {};
            for ii= AthrList%
                Athr_ii = tsAIN_St{ii,'Athr'};
                figure;
                [vars,fieldNams] = fieldsFind(tsAIN_St(ii,:),'tsAIN');
                nNthr = length(fieldNams);
                NthrRange = [1:nNthr]';
                for Nthr = NthrRange'

            %     bar(tsAIN_St(ii).DateNum,tsAIN_St(ii).tsAIN_K); %Fig.7(a)
            %     hold on
            %     bar(tsAIN_St(ii).DateNum,tsAIN_St(ii).tsAIN_S); %Fig.7(a)
            %     legend({'Kurtosis','Skewness'})
                    

                    tsAIN_sum = sum(cell2mat(vars),2);
                    anoTM = NaN(size(tsAIN_sum));
                    anoTM(tsAIN_sum>=Nthr) = Nthr; %convert true/false to double (1 or 0).
                    plot(tsAINdt,anoTM,'-bo');
                    hold on
                end
            
                ax = gca;
                tickYLabels = strings([nNthr,1]);
                tickYLabels(:) = 'Nthr=%d';
                tickYLabels = compose(tickYLabels,NthrRange);
                [ticks,tickXLabels] = datetime_ticks(tsAINdt,'yyyy/mm',4,'months');
                set(ax,'YTickLabel',tickYLabels,'YTick',NthrRange,'YLim',[0,round(max(NthrRange)+1)],...
                    'XTickLabel',tickXLabels,'XTick',ticks);
                xtickangle(45); % rotate YLabel to horizontal
                LatLon = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
                ax.YGrid = 'on';
                title(sprintf('[%s] %s, Athr = %.1f, Rc = %d km',StNm,folderNm,Athr_ii,Rc_non_GEMSTIP));
                EQinRange(CWBcatalogM5,'TimeRange',timeRange_i,...
                        'Radius',{LatLon,Rc_non_GEMSTIP},'PlotVerticalLine',ax);%,'MagnitudeTag',1);
                legend({SKMVtype},'Location','NorthEast');
                set(gcf,'Position',FigPosAno);
                adjPlot('thicker','larger');
                fNm = sprintf('[%s]anoTM_Athr=%.1f(%s).png',StNm,Athr_ii,SKMVtype);
                print(fullfile(figPath,fNm),'-dpng',Res1);
                figcell = [figcell, fig2im(gcf)];
                close;
%                 ranges = intervalSplit(tsAINdt,splitters);
%                 ranges(2,:) = [];% No data in the middle
%                 diffranges = diff(ranges,1,2);
%                 PosFactor = diffranges/min(diffranges);
% 
%                 for iii = 1:size(ranges,1)
%                     EQinRange(CWBcatalogM5,'TimeRange',ranges(iii,:),...
%                         'Radius',{LatLon,Rc},'PlotVerticalLine',ax);%,'MagnitudeTag',1);
%                     set(gca,'XLim',ranges(iii,:));
%                     
%                     if iii == size(ranges,1)
% %                         ax.Title = []; %delete the title of 2nd plot
%                         figHeight = figHeight*0.93;
%                     end
%                     
%                     set(gcf,'Position',[10,10,round(700*PosFactor(iii)),figHeight]);
% 
%                     fNm = sprintf('[%s]anoTM_Athr=%.1f(%s)_%d.png',StNm,Athr_ii,SKMVtype,iii);
%                     save2 = fullfile(figPath,fNm);
%                     print(save2,'-dpng',Res1);
%                     figcell = [figcell, fig2im(gcf)];
%                 end
%                 close;

            end
            img2 = cropimg(figcell);
            [~,imgSt] = im2im(img2,'AlignLeft');
            fNm = sprintf('[%s]anoTM_(%s).png',StNm,SKMVtype);
            save3 = fullfile(figPath,fNm);
            imwrite(imgSt,save3);
        
    
    end
    winopen_alt(figPath);
end %if warninginput

%% GEMSTIP/MagTIP
PredParam_sorted = sortrows(PredParam,'Athr'); % this increase the speed.

TimeRng_tmp = TIP_time.range_train;
GenerateRankedModels(CWBcatalog,PredParam_sorted,StationLocation_tb,...
    pf_iters,TimeRng_tmp,configs.dir_tsAIN,configs.dir_molchan_train,PredParamSetting,...
    'ProgressBar',1,'Overwrite',SkipExistingRankedModels);%     'checkpoint',8

% GEMSTIP TEST 
if settings_cwb.do_Test && strcmp(PredParamSetting,'test')
    StationLatLon1 = [StationLocation_tb.Lat, StationLocation_tb.Lon];
    PredParam_sorted = sortrows(PredParam,'Athr'); % this increase the speed.
    % PredParam_sorted = PredParam_sorted(109999:129999,:); %  ONLY FOR TESTING

    nModel=size(PredParam_sorted,1); 
    nModel_k = ceil(nModel/pf_iters);

    idx0 =1;
    idx1 = nModel_k;
    PredParam_k = cell(pf_iters,1);
    PredParam_test = table; % create an empty table
    for i = 1:pf_iters
        PredParam_k{i} = PredParam_sorted(idx0:idx1,:);
        idx0= idx0 + nModel_k;
        idx1= idx1 + nModel_k;
        idx1 = min(idx1,nModel);
        PredParam_test = [PredParam_test;PredParam_k{i}];
    end
    if isequal(PredParam_test{:,:},PredParam_sorted{:,:})
        disp('PredParam slicing success.');
    else
       error('PredParam slicing not sucessful'); 
    end

    totalSts = length(StationLatLon1);
    tic; H = timeLeft0(totalSts,'SOP__2019: GEMSTIP');
    for iSt = 1:totalSts

        StNm = StationLocation_tb.Properties.RowNames{iSt};
        tsAIN_list = datalist(['[',StNm,']','tsAIN*'],configs.dir_tsAIN);
        tsAIN_table = only1field(tsAIN_list.fullpath{end});
        StLatLon = StationLatLon1(iSt,:);

    %     tic;

    %     score_Mol = cell(pf_iters,1);
        PredParamMol = cell(pf_iters,1);
    %     parpool('local',pf_iters);%數字代表核心數

        if ~exist('TimeCut','var')
            error("please uncomment assignin('base','TimeCut',TimeCut) in TIPs.m");
        end

        parfor k = 1:pf_iters
    %         [PredParamMol{k}] = TIPs_critical_IndStStable_ver_20190925(StLatLon,tsAIN_table,...
    %             CWBcatalog,PredParam_k{k},'TimeRange',TimeCut);%'TimeRange',[dt0,dt1]
            [PredParamMol{k}] = TIPs_critical_stable_ver_20190924(StLatLon,tsAIN_table,...
                CWBcatalog,PredParam_k{k},'TimeRange',TimeCut);%'TimeRange',[dt0,dt1]
        end
    %     delete(gcp('nocreate')); %關掉parfor
    %     toc

        PredParamMol2 = vertcat(PredParamMol{:});
        [RankedModels_st_test,PPidx] = sortrows(PredParamMol2,'MolchanScore','descend');
    %     PredParamMol2 = PredParamMol2(PPidx,:);
        fnamei= sprintf('[%s]RankedModel_%s',StNm,PredParamSetting);
        save(fullfile(configs.dir_molchan_test,fnamei),'RankedModels_st_test')
        [H] = timeLeft1(toc,iSt,H);
    end

    if ~isequal(RankedModels_st_test,RankedModels_st)
        warning('TIP.m Test Failed (only last station)');
    else
        disp('TIP.m Test Passed (only last station)')
    end
end
%% Test GEMSTIPS
if settings_cwb.do_Test
    molchan_list = datalist('*RankedModel*',configs.dir_molchan_train);
    molchan_test_list = datalist('*RankedModel_test*',configs.dir_molchan_test);
    switch PredParamSetting
        case 'test'
            for i = 1:size(StationLocation_tb,1)
                RankedModels_st_test_i = only1field(molchan_test_list.fullpath{i});
                RankedModels_st_i = only1field(molchan_list.fullpath{i});
                StNmO = regexp(molchan_list.name{i},'(?<=\[)\w+(?=\])','match','once');
                StNmT = regexp(molchan_test_list.name{i},'(?<=\[)\w+(?=\])','match','once');

                if ~isequaln(RankedModels_st_test_i,RankedModels_st_i)
                    warning('TIP.m Test Failed [Original: %s; Test: %s]',StNmO,StNmT);
                else
                    disp('TIP.m Test Passed')
                end
            end
    end    
end

%% max score of Molchan_CB 
if settings_cwb.do_Plot
alpha = 0.05; % 顯著水平
Neq = 10; % Presumed number of earthquakes. See EQ.25 in HongJia
[molt_cb,moln_cb] = Molchan_CB(Neq,alpha);
score_cb = 1 - molt_cb - moln_cb;
fprintf('Maximum of D_{cb} = %.2f\n',max(score_cb));
end
%% plot molchan score and export table in excel.

if settings_cwb.do_Plot
    StList = StationLocation_tb.Row;
    NoF = length(StList);
%     modelList = datalist('*RankedModel*',path_molchan_train);
    [RankedModels,~] = MolchanScore_load(BestN,nModels_Comb,configs.dir_molchan_train,StList);
    folderNm = sprintf('Molchan Score (%s) %s',SKMVtype,TIP_time.tag_train);% TagTrainRange
    fNmexcel = sprintf('%s_MolchanScore',SKMVtype);
    figPath_mol = fullfile(configs.dir_save_figures,folderNm);
    mkdir(figPath_mol);
%     alpha = 0.05; % 顯著水平
%     Neq = 10; % Presumed number of earthquakes. See EQ.25 in HongJia
    A0 = 1; % excel range (initially start from A1, the up-left corner.)
    B0 = 2; % excel range of the table to write (start from B2).
    NoR_tb = BestN +3; % every table has (BestN = 10) rows + 2 rows for title + one blank
    NoFg = 1;fi = {};
    
    if ~exist('alpha','var') || ~exist('Neq','var')
        error("please execute the section 'max score of Molchan_CB' first.");
    end
    
    for j = 1:NoF

        StNm = StList{j}; % StNm = regexp(modelList.name{j},'(?<=\[)[A-Z]+','match','once');
        if strcmp(StNm,'KM') %no earthquake in KM. The plot is empty
            continue
        end
        RankedModels_st = RankedModels.(StNm);


        fi{NoFg} = figure; NoFg = NoFg +1;
        plot(RankedModels_st.MolchanAlarmedRate,RankedModels_st.MolchanMissedRate,'o')
        hold on 
        plot([0,1],[1,0],'r')
        titlei = sprintf('Molchan diagram (Station Code: %s)',StNm);
        title(titlei);
        
        % plot confidence boundary
%         LatLon_j = [StationLocation_tb.Lat, StationLocation_tb.Lon];
%         catalog_iMod = EQinRange(CWBcatalogM5,'Radius',{LatLon_j,Rc_ij},...
%                     'ConsiderDepth',1);
        [molt_cb,moln_cb] = Molchan_CB(Neq,alpha);
        plot(molt_cb,moln_cb);
        
        xlim([0,1]); ylim([0,1]);
%         xlabel('\tau, fraction of alarmed cells)');
%         ylabel('n, fraction of missing earthquakes');
        xlabel('$\tau$ (fraction of alarmed cells)','Interpreter','latex');
        ylabel('$\nu$ (fraction of missing earthqakes)','Interpreter','latex');

        
        cbtxt = sprintf('CB for N_{EQ}=%s, \\alpha=%s',num2str(Neq),num2str(alpha));
        besttxt = sprintf('Best %d models',BestN);
        % plot best 10 models
        model_st_sorted = sortrows(RankedModels.(StNm),'MolchanScore','descend'); %應該是不必要的。因為儲存的時候已經排序過
        bestNmodels = model_st_sorted(1:BestN,:);
        for bN = 1:BestN
            Xb = bestNmodels.MolchanAlarmedRate(bN);
            Yb = bestNmodels.MolchanMissedRate(bN);
           plot(Xb,Yb,'go'); 
%            text(Xb+0.01,Yb-0.04,num2str(bN),'Color','g');
        end
        lgd = legend({'Performance of each model','Random Guess',cbtxt,besttxt},...
            'Location','WestOutside');
%         lgd.Position = lgd.Position + [0.001,0,0,0];
%         lgd.String(end-8:end)=[];
        axis square
        set(gcf,'Position',[220.2000  334.6000  812.8000  339.2000]);%[50,50,740,388]);
        % duplicate the y axis to the right and invert the tick labels.
        ax1 = gca;
        [ax2] = dupAx(ax1);
        ax2.YTickLabel = flipud(ax2.YTickLabel);
        ax2.YLabel.String = '$P_{hit}$ (hit rate)';
        ax2.YLabel.Interpreter = 'latex';
        adjPlot('thicker','larger')

        % position adjustment
        ax2.Position = ax1.Position - [0.085,0,0,0];

        
        
        fNm = sprintf('[%s]_%s_MolchanScore',StNm,SKMVtype);
        print(fullfile(figPath_mol,fNm),'-dpng',Res1);
%         tb_excel = table;
%         tb_excel.Station = 
        
        sht_j = 1; % sht_j = j;
        stNmRankRng = sprintf('A%s:A%s',num2str(A0),num2str(A0+1)); % e.g. 'A1:A2'
        RankNumRng = sprintf('A%s:A%s',num2str(A0+2),num2str(A0+2+BestN-1)); % e.g. 'A3:A12';
        tbRng = sprintf('B%s',num2str(B0)); % e.g. 'B2'
        
        
        filepath = table2excel(bestNmodels,'Folder',figPath_mol,'File',fNmexcel,...
            'Option',{'Sheet',sht_j,'Range',tbRng});
        chineseNmC = StationLocation_tb{StNm,'format'};
        writematrix([sprintf("%s站(%s)",chineseNmC{:},StNm);"Rank"],filepath,...
            'Sheet',sht_j,'Range',stNmRankRng);
        writematrix([1:BestN]',filepath,...
            'Sheet',sht_j,'Range',RankNumRng);
        
        A0 = A0 + NoR_tb; 
        B0 = B0 + NoR_tb; 


    end
    im = fig2im(fi{:});

    figure; montage(im);
    close(fi{:});

    fNm = sprintf('[All]_%s_MolchanScore.png',SKMVtype);
    print(fullfile(figPath_mol,fNm),'-dpng',Res1);
    winopen_alt(figPath_mol);
end% warninginput




%% GEMSTIP Joint station method (use RankedModelsBestRand)
% Why including station MS has large negative effects? 
%     Ans. probably because there's no score in the near-future predict phase, 
%     and low scores the far-future predict phase.)

% execute this section consecutively will calculate mean molchan score with
% expanded forecast range.
% if ~exist('RankedModelsBestRand','var')
%    error('Please execute MolchanScore_load.m first.');
% end
if settings_cwb.do_JointStation
% list_tsAIN_path = datalist('*tsAIN*',configs.dir_tsAIN);
% LatLons = struct();
% NoF = size(list_tsAIN_path,1);
% for j = 1:NoF
%     StNm = StationLocation_tb.Row{j};
%     LatLons.(StNm) = [StationLocation_tb{StNm,'Lat'},StationLocation_tb{StNm,'Lon'}];
% end

% Warning: RankedModelsBestRand.KM can be empty (RankedModelsBestRand.KM=[] not 100x11 table)

% StList_all = StationLocation_tb.Row;
noTest = 5; % number of saved TIP and EQK, for testing only.
% dS = 0.1; % degree;

% nXcordinate = TwLonLim(1):dS:TwLonLim(2); % twLon
% nYcordinate = TwLatLim(1):dS:TwLatLim(2); % twLat

% if exist('doit_JSt','var') ||exist('Summary_JSt','var')
%     error('clear doit_JSt Summary_JSt before running this section.');
% end

StList_loadMolScore = StationLocation_tb.Row;
skipstation = {'KM'};%{'KM','MS'};%{'KM','PT','CS','MS'};
[Lia,Locb] = ismember(skipstation,StList_loadMolScore);
StList_loadMolScore(Locb) = [];
StList_selected = StList_loadMolScore;
fieldfmt = "yr%s_%s";
tableRowFmt = 'yymmdd';
paths_MolchanX_trn = datalist('MolchanScore_*',configs.dir_dataderived);

% match_trn_as_names = '(?<tag_0>(?<=\[)\d{8})-(?<tag_1>\d{8}(?=\]))';

MolXNames = [paths_MolchanX_trn.name{:}];
% trn_tags = regexp(MolXNames,match_trn,'match'); % '(?<=trn\[).+?(?=\])'
% trn_tags = unique(trn_tags);
% numeltrntags = length(trn_tags); % must unique first.
% 
% N_col = ceil(numeltrntags/pf_iters);
% N_addEmptyCells = N_col*pf_iters - numeltrntags;
% trn_tags =  [trn_tags, cell(1,N_addEmptyCells)];
% trn_tags_1 = reshape(trn_tags,[],N_col);
tmpO = get_tags(MolXNames,'Prefix','trn','reshape',{'Row',pf_iters},'unique',1);
trn_tags_1 = tmpO.trn;

numeltrntags = numel(trn_tags_1); % must unique first.

trn_datetime_str = regexp(trn_tags_1,match_trn_as_names,'names');
% trn_datetime_str = unique(trn_datetime_str); % can't use unique for structure

dT = 1;% day
dM = 3; % forecast duration in months expanded after one iteration.
forc_end = data_end;

Summary_struct.warning= struct(); % this suppresses repeated warning

to_skip = warninginput('Message',["To overwrite or skip existent files";"If no action set to_skip = false"],...
    'LeftButtonText','To skip','RightButtonText','To overwrite',...
    'Countdown',15);

suppress_progress = warninginput('Message',...
    ["Disable progress bar if parfor is used. ";"If no action set to_disable = false"],...
    'LeftButtonText','Use parfor/disable it','RightButtonText','Not use parfor/show progress',...
    'Countdown',15);

parpool('local',pf_iters); % optional
parfor pf_k = 1:pf_iters
    trn_tags_k = trn_tags_1(pf_k,:);
    trn_datetime_str_k = trn_datetime_str(pf_k,:);
    
    if ~suppress_progress && pf_k == 1
        tic; H = timeLeft0(numeltrntags,'Joint Station over different training period',[0,2]);
    end
    N_col = length(trn_tags_k);
    for i = 1:N_col

        if ~suppress_progress && pf_k == 1
            [H] = timeLeft1(toc,i,H);
        end
        trn_tag_i = trn_tags_k{i};
        if isempty(trn_tag_i)
            continue
        end
        trn_range_0 = datetime(trn_datetime_str_k{i}.tag_0,'InputFormat','yyyyMMdd');
        trn_range_1 = datetime(trn_datetime_str_k{i}.tag_1,'InputFormat','yyyyMMdd'); % 'today'

        doit_JSt = true;
        incfactor = 1;
        plot_x = {[trn_range_0;trn_range_1]};% the first range is the train period.
        plot_x_Tags = sprintf("trn[%s-%s]",datestr(trn_range_0,tableRowFmt),datestr(trn_range_1,tableRowFmt)); % string array
        field_Tags = sprintf(fieldfmt,datestr(trn_range_0,tableRowFmt),datestr(trn_range_1,tableRowFmt));

        t_today = trn_range_1;
        t_tomorrow = t_today + days(1);

        if t_today > forc_end - days(1) 
            % if the condition is met, error will occurred because frc1 will be
            % larger than data_end. Therefore, continue to next loop to avoid
            % error.
            continue
        end

        while doit_JSt % lengthen forecasting phase by dM a time.
            frc1 = trn_range_1 + incfactor*calmonths(dM); 
            incfactor = incfactor +1;
            frcRange = [t_tomorrow;min([frc1,forc_end])];
            fTag_i = sprintf(fieldfmt,datestr(t_tomorrow,tableRowFmt),datestr(frc1,tableRowFmt));
            Tag_i = sprintf("frc[%s-%s]",datestr(frcRange(1),tableRowFmt),datestr(frcRange(2),tableRowFmt));
            plot_x = [plot_x,{frcRange}];
            plot_x_Tags = [plot_x_Tags,Tag_i]; % string array
            field_Tags = [field_Tags,fTag_i];
            if frc1>=forc_end
                doit_JSt = false;
            end
        end
        numelfrctags = length(plot_x_Tags);

        match_trn_i = sprintf('MolchanScore*trn[%s]*',trn_tag_i);
        path_freqs = datalist(match_trn_i,configs.dir_dataderived); % same time range, different frequency band
    %     path_freqs = datalist(sprintf('MolchanScore_*[%s]',trn_tag_i),configs.dir_dataderived);
        NofreqBand = size(path_freqs,1);
        if NofreqBand > 4 % expected number of freqBands/folders
            winopen_alt(configs.dir_dataderived);
            error('please check if there are superfluous folders.');
        end
        for j = 1:NofreqBand
            Summary_JSt = struct();
            path_j = path_freqs.fullpath{j};
            if isempty(datalist('*.mat',path_j))
                continue % 2020/04/11: If folder does not contain any matfile, skip this folder.
            end
            
            [~,RankedModelsBestRand] = MolchanScore_load(BestN,nModels_Comb,...
                                    path_j,StList_selected);
            freqBand = RankedModelsBestRand.Tag;

            save2_tmp = fullfile(configs.dir_joint_station_vars_mol,sprintf('Summary_JSt_fb[%s]_trn[%s].mat',freqBand,trn_tag_i));

            if to_skip && isfile(save2_tmp) % if file exists, then skip if to_skip is true.
                continue
            end

            pathlist_tsAIN = datalist(sprintf('tsAIN*%s*',freqBand),configs.dir_dataderived);

            if size(pathlist_tsAIN,1)~=1
                winopen_alt(configs.dir_dataderived);
                error('There is no corresponding tsAIN folders. Please check the opened folder.');
            end

            pti = pathlist_tsAIN.fullpath{1};

    %         trn_tag_j = regexp(path_j,match_trn_as_names,'names');
            if ~strcmp(regexp(path_j,match_trn,'match'),trn_tag_i)
                error(['trn_tag_i should be the same as trn_tag_j, ',...
                    'because path_j for MolchanScore is that of the same training time ',...
                    'but of different frequency bands.'])
            end


            tmSeq_trn = [trn_range_0:days(dT):trn_range_1]'; %記錄點
            [S_tb_trn,S_struct_trn] = TIPs_JointStation(tmSeq_trn,CWBcatalog,...
                    LatLons,RankedModelsBestRand,pti,'Inherit',Summary_struct); %記錄點

            if ~suppress_progress && pf_k == 1
                tic2 = toc; H2 = timeLeft0(numelfrctags,'Joint Station over different forecast period',[0,1]);
            end

            for Rng_i = 1:numelfrctags 
                if ~suppress_progress && pf_k == 1
                    toc2 = toc - tic2; [H2] = timeLeft1(toc2,Rng_i,H2);
                end
                truncatedRange = plot_x{Rng_i};
                truncatedRangeTag = plot_x_Tags{Rng_i};
                tmBeg = min(truncatedRange);
                tmEnd = max(truncatedRange);
                tmSeq_frc = [tmBeg:days(dT):tmEnd]'; % datetime array in forecast range
                [S_tb_frc,S_struct_frc] = TIPs_JointStation(tmSeq_frc,CWBcatalog,...
                    LatLons,RankedModelsBestRand,pti,'Inherit',S_struct_trn,...
                    'CalculateProbability',S_tb_trn.HitRate);
                frc_tag = sprintf('%s-%s',datestr(tmBeg,'yyyymmdd'),datestr(tmEnd,'yyyymmdd'));
                save2_prob = fullfile(configs.dir_joint_station_vars_prb,...
                    sprintf('S2_fb[%s]_trn[%s]_frc[%s].mat',freqBand,trn_tag_i,frc_tag));
                parsave1(save2_prob,S_struct_frc);

                % Try to preallocate structure in this section to increase speed.
                sumtype = {'mean','std'};
                for a = 1:2
                    ot=tableSum(S_tb_frc,sumtype{a});
                    endot = ot(end,:);
                    endot.Properties.RowNames = plot_x_Tags(Rng_i);
                    if isfield(Summary_JSt,sumtype{a})
                        Summary_JSt.(sumtype{a}) = [Summary_JSt.(sumtype{a});endot];
                    else
                        Summary_JSt.(sumtype{a}) = endot;
                    end
                end

            end

            if ~suppress_progress && pf_k == 1
                delete(H2.waitbarHandle);
    %             save(save2_tmp,'Summary_JSt');
    %         else
    %             parsave1(save2_tmp,Summary_JSt);
            end
            parsave1(save2_tmp,Summary_JSt);

        end
    end

end

delete(gcp('nocreate')); % manually delete parfor. % this is optional.

if ~suppress_progress
    delete(H.waitbarHandle);
end


% This section will save only the last
% Probability = Probability/nModels_Comb;
% suffixP = sprintf('[%s-%s]',datestr(TR1,'yyyymmdd'),datestr(TR2,'yyyymmdd'));
% save(fullfile(configs.dir_EQK_probability,'Probability.mat'),'Probability');
% save(fullfile(configs.dir_EQK_probability,'Summary.mat'),'Summary');
% save(fullfile(probPath,'cataM.mat'),'cataM_j');
% save(fullfile(configs.dir_EQK_probability,'tmSeq.mat'),'tmSeq'); % datetime array in forecast range
% warning("Only the last 'Summary' and 'Probability' will be saved. (fixed required)");

end

%% Plot United Station Rcs on Taiwan map (2020 Mid Report)
if settings_cwb.do_Plot
trn = '20081114-20151115';
frc = '20151116-20190415';
% MolScore4ProbForc = datalist(sprintf('S2*trn[%s]_frc[%s]*',trn,frc),configs.dir_joint_station_vars_prb);
% S = only1field(MolScore4ProbForc.fullpath{1});
frcdt = str2duration(frc).datetime;
PlotEpicenterOptions = {'regular',...% 'filled'
    'MarkerSize',[1,6],'MarkerEdgeColor','r','LineWidth',1.3};
MolScoreAll = datalist(sprintf('Molchanscore*trn[%s]*',trn),configs.dir_dataderived);
f = cell(1,size(MolScoreAll,1));
for i = 1:size(MolScoreAll,1)
    RankedModel_list = datalist('*RankedMod*.mat',MolScoreAll.fullpath{i});
    StationNames = regexp([RankedModel_list.name{:}],'(?<=\[).+?(?=\])','match');
    [RankedModels,~] = MolchanScore_load(BestN,nModels_Comb,...
                                            MolScoreAll.fullpath{i},StationNames);
                                        
    StationList = RankedModels.StationList;
    [~,Locb] = ismember('KM',StationList);
    StationList(Locb) = []; % delete KM
    f{i} = figure;
    county_plot('LineWidth',0.4,'EdgeAlpha',0.5);
    
    
    
    for k = 1:length(StationList) % draw circles
        StNm = StationList{k};
        MolchanScoreTable = RankedModels.(StNm);
        MolchanScoreTable = MolchanScoreTable(1:BestN,:);
        StLat = StationLocation_tb{StNm,'Lat'};
        StLon = StationLocation_tb{StNm,'Lon'};
        [latitude_span_in_deg,longitude_span_in_deg] = km2latlon_rough(MolchanScoreTable.Rc,StLat);
        MolchanScoreTable.Rc
        meanlatlon = mean([latitude_span_in_deg,longitude_span_in_deg],2);
        
        x = NaN(size(meanlatlon));
        y = x;
        x(:) = StLon;
        y(:) = StLat;
        circles(x,y,meanlatlon,'FaceAlpha',0,'EdgeAlpha',0.35,'EdgeColor','#5bc688','LineWidth',2);
    end
    
%     EQinRange(CWBcatalog,'PlotEpicenter',PlotEpicenterOptions,'TimeRange',frcdt,'Magnitude',6);
    plot(StationLocation_tb.Lon,StationLocation_tb.Lat,'b^','MarkerSize',4, 'MarkerFaceColor','b'); % plot station
    
    for k = 1:length(StationList) % add station name tags
        StNm = StationList{k};
        StLat = StationLocation_tb{StNm,'Lat'};
        StLon = StationLocation_tb{StNm,'Lon'};
        t = text(StLon+0.1,StLat,StNm,'FontSize',10,'Color','b');
        t.FontWeight = 'bold';
%         textbox(StLon+0.1,StLat,StNm,'FontSize',10,'Color','b',... % text options
%             'FaceColor',[0.90,0.90,0.7],'ModifyTextExtent',[0.04,-0.03]);        
    end
    
    axis equal
    box on
    xlim([119.5, TwLonLim(end)]);
    ylim(TwLatLim);
    xlabel('Longitude($^\circ$)','Interpreter','latex');
    ylabel('Latitude($^\circ$)','Interpreter','latex');

    set(gcf,'Position',[2146 378 384 565]);
%     adjPlot('larger');
    fb = regexprep(get_tags(MolScoreAll.name{i},'Prefix','tag').tag{:},'filtered_','');
    title(sprintf("preset '%s'",fb));
end
ims = fig2im(f{:},'dpi',400);
ims = cropimg(ims,'EdgeCrop',{'down'});

% concatenate images along the direction of 1d cell array containing images.
[~,imL] =  im2im(ims(1:2)); % left two panels
[~,imR] =  im2im(ims(3:4)); % right two panels

[~,imF] =  im2im({imL,imR});
imF = imageTitle(imF,'聯合測站法各測站偵測半徑一覽');


imwrite(imF,fullfile(configs.dir_save_figures,'EffectiveRadius.png'));
figure;
imshow(imF);
close all

winopen_alt(configs.dir_save_figures);
end

%% plot Summary of molchan score (joint station method using RankedModelsBestRand)
% diary: show trn'151115 and therein after?
if settings_cwb.do_Plot
%     MolPath = configs.dir_joint_station_vars_mol; %fullfile(configs.dir_dataderived,'JointStationVariables');%,'problematic');
    MolScoreList_all = datalist('Summary_JSt*',configs.dir_joint_station_vars_mol);
    
    O = get_tags([MolScoreList_all.name{:}],'Prefix','trn','unique',1);
    trn_tags = O.trn;
    
    for k =1:length(trn_tags)
        trn_tag_k = trn_tags{k};
        match_trn_k = sprintf('Summary_JSt*trn[%s]*',trn_tag_k);
        MolScoreList_k = datalist(match_trn_k,configs.dir_joint_station_vars_mol);
        NoMR = size(MolScoreList_k,1);
        lgdM = cell(NoMR,1);
        figure;
        for i = 1:NoMR
            Summary_JSt = only1field(MolScoreList_k.fullpath{i});
            if i ==1
                xtlb = Summary_JSt.mean.Properties.RowNames;
                N_data = numel(xtlb);
                sx = 1:N_data;
            end
            
    %         if i>1 && ~isequal(xtlb,Summary_JSt.mean.Properties.RowNames) %Uh, what is xtlb??
    %             error('xlabel (e.g. FrcXXXXXXXX) is not matched.');
    %         end
            snm = MolScoreList_k.name{i};
            sy = Summary_JSt.mean{xtlb(:),'MolchanScore'};
            
            serr = Summary_JSt.std{xtlb(:),'MolchanScore'};
            erb = errorbar(sx,sy,serr);
            hold on
            lgdM(i) = {regexp(snm,'(?<=fb\[).+?(?=\])','match','once')};
        end
        xtlb1 = regexprep(xtlb,'\[',"'"); % replace [ with '
        xtlb1 = regexprep(xtlb1,'\]',''); % delete ]
        xtlb1 = regexprep(xtlb1,'\d+-',''); % delete the first time tag
        legend(lgdM,'Interpreter','none','Location','eastoutside');
        ax = gca;
        fx = gcf;
        fx.Position = [100 100 860 420];%[100, 100, max([80+N_data*30,500]), 420];
        ax.XTick = sx;
        ax.XTickLabel = xtlb1;
        ax.XTickLabelRotation = 45;
        ylabel('$\bar{d}$ (fitting degree)','Interpreter','latex');
        title9 = {'Fitting degrees of forecasting TIP of different lengths';...
            sprintf('(time of tranining phase: %s)',trn_tag_k)};
        title(title9);
        adjPlot(ax,'larger','thicker');
        tmp_nm = sprintf('MolchanScoreSummary_trn[%s].png',trn_tag_k);
        print(fullfile(configs.dir_save_figures,tmp_nm),'-dpng','-r200');
        close;
    end
    winopen_alt(configs.dir_save_figures);
end

%% plot molchan score v.s. duration of training phase.
% diary: show trn'151115 and therein after?

if settings_cwb.do_Plot

paths_MolchanX_trn = datalist('Summary_*',configs.dir_joint_station_vars_mol);
prefix = 'trn'; % to find files of different training time interval
id_trn = 2;
MolXNames = [paths_MolchanX_trn.name{:}];
Ot = get_tags(MolXNames,'Prefix',prefix,'reshape',{'Row',pf_iters},'unique',1);
prefix_tb = 'MolchanScore_';
dt_tags = Ot.(prefix);
N_tags = numel(dt_tags); % must unique first.
dt_str = regexp(dt_tags,match_trn_as_names,'names');

Of = get_tags(MolXNames,'Prefix','fb','unique',1);
freqBands = Of.fb;
freqBands2 = regexprep(freqBands,' ','_'); % replace Space ' ' by Underline '_'

Nm_col = [{'duration_trn'},cellfun(@(x) [prefix_tb,x],freqBands2,'UniformOutput',false)];


N_col = length(Nm_col);
% varTypes = cell(1,N_col);
% varTypes(:) = {'double'};

% varTypes(1) = {'double'};
% O_mean = table('Size',[N_tags,N_col],'VariableNames',Nm_col,'VariableTypes',varTypes);

nanarray = NaN(N_tags,1);
nanarrays = cell(1,N_col);
nanarrays(:) = {nanarray};
O_mean = table(nanarrays{:},'VariableNames',Nm_col);
O_std = O_mean;

for i = 1:N_tags
    tag_i = dt_tags{i};
    if isempty(tag_i)
        continue
    end
    Od = str2duration(tag_i,'datestrFormat','yymmdd','datetimeFormat','yyyyMMdd');
    trn_range = Od.datetime;
    training_years = years(Od.duration);
    t_today = trn_range(2);
    t_tomorrow = t_today + days(1);
    match_trn_i = sprintf('Summary_JSt*trn[%s]*',tag_i);
    
    MolX = datalist(match_trn_i,configs.dir_joint_station_vars_mol);
    O_mean.duration_trn(i) = training_years;
    O_std.duration_trn(i) = training_years;
    fprintf('Training durration: %.2f\n',training_years);
    for j = 1:size(MolX,1)
        freqTag = regexp(MolX.name{j},'(?<=fb\[).+?(?=\])','match','once');
        freqTag2 = regexprep(freqTag,' ','_');
        S = only1field(MolX.fullpath{j});
        colNm_i = [prefix_tb,freqTag2];
        try
            O_mean{i,colNm_i} = S.mean{id_trn,'MolchanScore'};
            O_std{i,colNm_i} = S.std{id_trn,'MolchanScore'};
            tag_j = S.mean.Properties.RowNames{id_trn};
            duration_j = get_tags(tag_j,'trn','once');
            dur = str2duration(duration_j);
            tag_frc = S.mean.Properties.RowNames{id_trn};
            fprintf('Success. tag_frc: %s; duration: %.1f years \n',...
                tag_frc,years(dur.duration));
        catch ME
%             if strcmp('MATLAB:table:UnrecognizedRowName',ME.identifier)
%                 rethrow(ME);fprintf('iter: %d, Forecast_range_tag: %s . Skip this file.\n',i,id_frc);
            if strcmp('MATLAB:table:RowIndexOutOfRange',ME.identifier)
                fprintf('S.mean or S.std has only %d rows, but id_frc = %d. Skip this file.\n',size(S.mean,1),id_trn);
            else
                rethrow(ME);
            end
            
        end
        
    end
    
end
disp('Mission Complete')


figure;
lgd = Nm_col(2:end);
lgd = regexprep(lgd,'(MolchanScore_filtered|MolchanScore)','');
lgd = regexprep(lgd,'_',' ');
for i = 2:length(Nm_col)
    errorbar(O_mean.(Nm_col{1}),O_mean.(Nm_col{i}),O_std.(Nm_col{i}));
    hold on
end
legend(lgd);
xlabel('duration of training phase (years)');
ylabel('Fitting degree');
tag_frc_last = regexprepx(tag_frc,{'frc\[','-','\]'},{'20','-20',''});
title1 = {'Fitting degree of forecasting TIP over different length of training phase';...
    sprintf('(time of forecasting phase: %s)',tag_frc_last)};
title(title1);% ,years(dur.duration)
adjPlot('larger','thicker');
set(gcf,'Position',[105   342   943   420]);
print(fullfile(configs.dir_save_figures,...
    sprintf('MolchanScore_vs_TrainingDurations_frcid[%.2d]',id_trn)),'-dpng',Res1);
end

%% plot molchan score of different forecasting periods
if settings_cwb.do_Plot
trnstr = '20091114-20151115';
% trnstr = '20081114-20151115';
% trnstr = '20061115-20151115';
frcstr = '20151116-20190415';
paths_MolchanX_trn = datalist(sprintf('Summary_*trn[%s]*',trnstr),...
    configs.dir_joint_station_vars_mol);
nFreqs = size(paths_MolchanX_trn,1);
lgds = cell(1,nFreqs);
figure;
frcid = 2;

for i = 1:nFreqs
    S = only1field(paths_MolchanX_trn.fullpath{i});
    sy = S.mean.MolchanScore(frcid:end);
    sx = 1:length(sy);
    stdy = S.std.MolchanScore(frcid:end);
    
    if exist('xlabel_i','var') && xlabel_i ~= S.mean.Properties.RowNames(frcid:end)
        error('Inconsistent row names.');
    else
        xlable_i = S.mean.Properties.RowNames(frcid:end);
    end
    errorbar(sx,sy,stdy);
    hold on
    lgd_i = get_tags(paths_MolchanX_trn.name{i},'fb','once');
    lgd{i} = regexprepx(lgd_i,{'filtered_','_'},{'',' '}); % delete 'filtered_' and replace '_' by ' ';
    shortest_frc = S.mean.Properties.RowNames{2};
    fprintf('[%s]%s mean molchan score = %.3f \n',...
        lgd_i,shortest_frc,S.mean{shortest_frc,'MolchanScore'});
end
ax = gca;
fx = gcf;
legend(lgd);
ax.XTick = sx;
ax.XTickLabel = regexprepx(xlable_i,{'frc\[','\]'},{'',''});
ax.XTickLabelRotation = 45;
ax.XLabel.String = 'time of forecasting phase';
ax.YLabel.String = 'fitting degree';
fx.Position = [488 342 845 420];
adjPlot('larger','thicker');
title({'Fitting degrees of the forecasting TIPs';sprintf('(time of training phase: %s)',trnstr)});
print(fullfile(configs.dir_save_figures,'MolchanScore_vs_ForecastingIntervals'),'-dpng',Res1);

% fitting degree of full range
paths_MolchanX_trn = datalist('*FullRange*',...
    'D:\GoogleDrive\1MyResearch\DATA\GM_DATA_derived\Set_13 - 2019 - 2\JointStationVariables');
nFreqs = size(paths_MolchanX_trn,1);
lgds = cell(1,nFreqs);
frcid = 2;

for i = 1:nFreqs
    S = only1field(paths_MolchanX_trn.fullpath{i});
    lgd_i = get_tags(paths_MolchanX_trn.name{i},'tag','once');
    
    fprintf('[%s] mean molchan score = %.2f \n',...
        lgd_i,mean(S.MolchanScore));
    fprintf('[%s] mean hit rate = %.2f \n',...
        lgd_i,mean(S.HitRate));
end


end
%% plot probability near earthquakes >= M6 (2020)
if settings_cwb.do_Plot
    
trnstr = '20081114-20151115';
% trnstr = '20061115-20151115';
frcstr = '20151116-20190415';
path_S2 = datalist(sprintf('*trn[%s]_frc[%s]*',trnstr,frcstr),configs.dir_joint_station_vars_prb);

sbm = 3; sbn = 4;
datePos = [0.34,0.94];
clrbarPos = [0.9325,0.0489,0.011,0.909];

StNms = fieldnames(LatLons);
Rcfixed = 100;
targetEQKs0 = EQinRange(CWBcatalog,'Magnitude',6);
targetEQKs = table;
for i = 1:length(StNms) % only earthquakes within 50 km of the stations
    targetEQKs = [targetEQKs;EQinRange(targetEQKs0,'Radius',{LatLons.(StNms{i}),Rcfixed})];
end
targetEQKs = unique(targetEQKs); % 'unique' will make table of ascending datetime descend;
targetEQKs = sortrows(targetEQKs,'DateTime','ascend'); % therefore, 'sortrows' must do in the last
NoCata = size(targetEQKs,1);

dtfrc = str2duration(frcstr);
quasiEQK =EQinRange(targetEQKs,'TimeRange',dtfrc.datetime);
quasiEQK.Properties.RowNames = quasiEQK.time;

redBoxMaster = true;

clrmap = flipud(hot);%flipud(hot);
clrmap = clrmap(1:round(size(clrmap,1)/3*2),:);
% clrmap(1,:) = [1,1,1]; % white
% clrmap(end,:) = [0,1,0]; % green for epicenter % feel free to comment this line
% clrmap(end,:) = [1,0,0]; % red for epicenter % feel free to comment this line
PlotEpicenterOptions = {'regular',...% 'filled'
    'MarkerSize',[1,6],'MarkerEdgeColor','k','LineWidth',1.5};%,'MarkerEdgeColor','g'};% 


climit = [0,1]; % needs attention
TwMainLonLim = TwLonLim;
TwMainLonLim(1) = 119.5; % just make the map focus on the main island of Taiwan
gap = 0.01;
marg_h = 0.09;
marg_w = 0.01;

sbno = sbm*sbn; %subplot
NoTi = sbm*sbn; 
daysAfterEQ = 5;
daysBeforeEQ = NoTi-daysAfterEQ-1;% 1 is for the day when event occurrd.

% figPos = [10,10,740,700];% for 3 by 3 subplots
figPos = [10,10,850,700];% for 3 by 3 subplots

for i = 1:size(path_S2,1) % iter around different frequency bands (with fixed frc & trn time)
    S2 = only1field(path_S2.fullpath{i});
    Probability = S2.Probability;
    Sz3_Prob = size(Probability,3);
    O2 = get_tags(path_S2.name{i},{'fb','trn','frc'},'once');
    frcdt = str2duration(O2.frc);
    tmBeg = frcdt.datetime(1);
    tmEnd = frcdt.datetime(2);
    tmSeq = tmBeg:1:tmEnd;
    if length(tmSeq)~=Sz3_Prob
        error(['Time sequence (tmSeq) and Probability is inconsistent. ',...
            'They should be the same length']);
    end
    
    figpDir_prb = fullfile(configs.dir_save_figures,...
        sprintf('Probability_fb[%s]_trn[%s]_frc[%s]',O2.fb,O2.trn,O2.frc));
    validpath(figpDir_prb,'mkdir');
    fig_i = figure;
    probFigNum = 1;
    
    quasiEQK.(O2.fb) = NaN(size(quasiEQK,1),1);
    
    for cata_i = 1:NoCata
%         try
        cata_table_i = targetEQKs(cata_i,:); 
%         catch
%            disp(); 
%         end
        cata_i_time = cata_table_i.DateTime;

        indTi = find(tmSeq<=cata_i_time,1,'last'); % find the 'last' '1' index
        if isempty(indTi)
           continue; 
        end
    %     evtday = tmSeq(indTi);
        TiRange = [indTi-daysBeforeEQ:indTi+daysAfterEQ];
        TiRange = TiRange(TiRange>0 & TiRange<=Sz3_Prob);

        sbi = 1;
        for Ti = TiRange
            today1 = tmSeq(Ti);
            C = Probability(:,:,Ti); %X:Lon; Y:Lat
            if sbi == daysBeforeEQ+1
                redBox = true;
            else
                redBox = false;
            end

            sbax = subtightplot(sbm,sbn,sbi); sbi = sbi+1;
            imc = imagesc(TwLonLim,TwLatLim,C);
            hold on
            county_plot('LineWidth',0.5,'EdgeAlpha',0.5);
            % plot station
            plot(StationLocation_tb.Lon,StationLocation_tb.Lat,'b^','MarkerSize',3, 'MarkerFaceColor','b');

            catatmp = EQinRange(targetEQKs,...
                'PlotEpicenter',PlotEpicenterOptions,...
                'TimeRange',[today1,today1 + days(1)]);
            catatmp.Properties.RowNames = catatmp.time;
    %             copyPlot(TwMap,fig_i,'ToSubplot',sbax);
            if ~isempty(catatmp)
                xy = [catatmp.Lon(1) catatmp.Lat(1)];
                [ij] = xy2ij(imc,xy);
                EQKprobability = imc.CData(ij(1),ij(2)); 
                quasiEQK{catatmp.time{1},O2.fb} = EQKprobability;
%                 imc.CData(ij(1),ij(2)) = 1;% feel free to comment this line
            end
            colormap(clrmap);
            sbax.CLim = climit; % or caxis(climit)
    %         imc.AlphaData = .8;
    %         circles(StationLocation_tb.Lon,StationLocation_tb.Lat,0.5,'FaceAlpha',0,'EdgeAlpha',0.5);
            sbax.YDir = 'normal';
            axis equal
            sbax.YLim = TwLatLim;
            sbax.XLim = TwMainLonLim;
            sbax.XTick = [];
            sbax.YTick = [];
            if  redBox
                xl1 = TwMainLonLim; yl2 = TwLatLim;
                rectangle('Position',[xl1(1) yl2(1) (xl1(2)-xl1(1)) (yl2(2)-yl2(1))],...
                    'LineWidth',3,'EdgeColor',[1 0 0],'LineStyle','--');
            end
    %         title(datestr(tmSeq(Ti)));
            lazytext(datestr(tmSeq(Ti)),'Position',datePos);
        end
        set(gcf,'Position',figPos);

        if sbi>sbno
            clrbar = colorbar;
            clrbar.Location = 'east';
            clrbar.Position = clrbarPos; % for vertical
    %         clrbar.Position = [0.14,0.06,0.74,0.016]; % for horizontal
            clrbar.TickDirection ='in';
            clrbar.AxisLocation = 'out';
            clrbar.Title.String = 'Probability';
            clrbar.Title.Rotation = -90;
            clrbar.Title.Units = 'normalized';
    %         titlePos = clrbar.Title.Position; titlePos(1) = -3; % % for horizontal
            titlePos = [3.3,0.50,0]; % for vertical
            clrbar.Title.Position = titlePos;
            clrbar.Title.FontSize = 12;
            titleTail = regexprepx(O2.fb,{'filtered_','_'},{'',' '});
            TextOption1 = {'FontSize',16,'FontWeight','Bold',...
                'HorizontalAlignment','Left','VerticalAlignment','Bottom'};
            TextPosition1 = {0.08,0};
            superTitle(sprintf('Probability Forecast (%s)',titleTail),...
                'TextOption',TextOption1,'TextPosition',TextPosition1);
            
            TextOption2 = {'FontSize',9,...
                'HorizontalAlignment','Right','VerticalAlignment','Bottom'};
            TextPosition2 = {0.92,0};
            cell4sprintf = {cata_table_i.Depth,cata_table_i.Mag,datestr(cata_table_i.DateTime,'HH:MM:ss')};
            superTitle(sprintf('Earthquake Properties: dep = %.1f km; ML = %.1f; time = %s',cell4sprintf{:}),...
                'TextOption',TextOption2,'TextPosition',TextPosition2);
            
            print(fullfile(figpDir_prb,sprintf('Probability(%.3d).png',probFigNum)),'-dpng','-r200'); 
            probFigNum=probFigNum+1;
            close;


            figure;
            sbi = 1;
           
        end
    end
    
end
    


table2excel(quasiEQK);






% cataM1 = sortrows(cataM,'DateTime','ascend'); notice that cataM should
% not be used in this section, since it preserves only that of the last
% model in RankedModelsBestRand.



end

%% plot probability near earthquakes >= M5
if settings_cwb.do_Plot
    
trnstr = '20081114-20151115';
% trnstr = '20061115-20151115';
frcstr = '20151116-20160515';
path_S2 = datalist(sprintf('*trn[%s]_frc[%s]*',trnstr,frcstr),configs.dir_joint_station_vars_prb);

sbm = 5; sbn = 5;

StNms = fieldnames(LatLons);
Mcfixed = 5;
targetEQKs0 = EQinRange(CWBcatalog,'Magnitude',Mcfixed);
targetEQKs = table;
Rcfixed = 100;
for i = 1:length(StNms) % only earthquakes within 50 km of the stations
    targetEQKs = [targetEQKs;EQinRange(targetEQKs0,'Radius',{LatLons.(StNms{i}),Rcfixed})];
end
targetEQKs = unique(targetEQKs); % 'unique' will make table of ascending datetime descend;
targetEQKs = sortrows(targetEQKs,'DateTime','ascend'); % therefore, 'sortrows' must do in the last
PlotEpicenterOptions = {'regular','filled',...
    'MarkerSize',[1,3],'MarkerFaceColor',[1 0 0]};%,'MarkerEdgeColor','g'};% 


clrmap = flipud(summer);%cool;%flipud(hot);
clrmap(1,:) = [1,1,1]; % white
% clrmap(end,:) = [1,0,0]; % red for epicenter
climit = [0,1]; % needs attention
TwMainLonLim = TwLonLim;
TwMainLonLim(1) = 119.5; % just make the map focus on the main island of Taiwan
gap = 0.004;
marg_h = [0.07, 0.07]; % [lower margin, upper margin]
marg_w = [0.005, 0.005]; % [left margin, right margin]

boxlw = 1.5;
boxstyle = '--';
boxcolor = [1 0 0];

sbno = sbm*sbn; %subplot
figPos = [0,0,395,650];% for 3 by 3 subplots

for i = 1:size(path_S2,1) % iter around different frequency bands (with fixed frc & trn time)
    S2 = only1field(path_S2.fullpath{i});
    Probability = S2.Probability;
    Sz3_Prob = size(Probability,3);
    O2 = get_tags(path_S2.name{i},{'fb','trn','frc'},'once');
    frcdt = str2duration(O2.frc);
    tmBeg = frcdt.datetime(1);
    tmEnd = frcdt.datetime(2);
    tmSeq = tmBeg:days(1):tmEnd;
    range_frc = 1:length(tmSeq);
    if length(tmSeq)~=Sz3_Prob
        error(['Time sequence (tmSeq) and Probability is inconsistent. ',...
            'They should be the same length']);
    end
    
    figpDir_prb = fullfile(configs.dir_save_figures,...
        sprintf('Probability_fb[%s]_trn[%s]_frc[%s]',O2.fb,O2.trn,O2.frc));
    validpath(figpDir_prb,'mkdir');
    fig_i = figure;
    probFigNum = 1;

    sbi = 1;
    for Ti = range_frc
        today1 = tmSeq(Ti);
        C = Probability(:,:,Ti); %X:Lon; Y:Lat

        sbax = subtightplot(sbm,sbn,sbi,gap,marg_h,marg_w); 
        sbi = sbi+1;
        imc = imagesc(TwLonLim,TwLatLim,C);
        hold on
        county_plot('LineWidth',0.8);
        % plot station
        plot(StationLocation_tb.Lon,StationLocation_tb.Lat,'b^','MarkerSize',3, 'MarkerFaceColor','b');

        catatmp = EQinRange(targetEQKs,...
        'PlotEpicenter',PlotEpicenterOptions,...
        'TimeRange',[today1,today1 + days(1)]);
        if ~isempty(catatmp)
            redBox = true;
        else
            redBox = false;
        end

        colormap(clrmap);
        sbax.CLim = climit; % or caxis(climit)
        sbax.YDir = 'normal';
        axis equal
        sbax.YLim = TwLatLim;
        sbax.XLim = TwMainLonLim;
        sbax.XTick = [];
        sbax.YTick = [];
        if  redBox
            xl1 = TwMainLonLim; yl2 = TwLatLim;
            rectangle('Position',[xl1(1) yl2(1) (xl1(2)-xl1(1)) (yl2(2)-yl2(1))],...
                'LineWidth', boxlw,...
                'EdgeColor',boxcolor,'LineStyle',boxstyle);
        end
%         title(datestr(tmSeq(Ti)));
        lazytext(datestr(tmSeq(Ti)),'Position',[0.44,0.94],'property',{'FontSize',8});
        if sbi>sbno || Ti == range_frc(end)
            set(gcf,'Position',figPos);
            clrbar = colorbar;
            clrbar.Location = 'southoutside';%'east';
%             clrbar.Position = [0.9325,0.04,0.011,0.909]; % for vertical
            clrbar.Position = [0.01,0.06,0.98,0.006]; 
    %         clrbar.Position = [0.14,0.06,0.74,0.016]; % for horizontal
            clrbar.TickDirection ='in';
            clrbar.AxisLocation = 'out';
            clrbar.Title.String = 'Probability';
%             clrbar.Title.Rotation = -90;
            clrbar.Title.Units = 'normalized';
            clrbar.Title.Position = [0.5, -8.2, 0];  %[3.3,0.50,0]; % for vertical
            clrbar.Title.FontSize = 8;
            titleTail = regexprepx(O2.fb,{'filtered_','_'},{'',' '});
            TextOption1 = {'FontSize',14,'FontWeight','Bold',...
                'HorizontalAlignment','Left','VerticalAlignment','Bottom'};
            AxesPosition = [0,0.94,1,0.06];
            superTitle(sprintf('Probability Forecast (%s)',titleTail),...
                'TextOption',TextOption1,'AxesPosition',AxesPosition);
            superLegend0(sprintf('EQK: M_L>=%.0f; Rc<=%.0f',Mcfixed,Rcfixed),...
        {'LineWidth', boxlw,'EdgeColor',boxcolor,'LineStyle',boxstyle},...
        'AxesPosition',[0.66,0.95,0.33,0.04]);
%             TextOption2 = {'FontSize',8,...
%                 'HorizontalAlignment','Right','VerticalAlignment','Bottom'};
%             TextPosition2 = {0.92,0};
%             cell4sprintf = {cata_table_i.Depth,cata_table_i.Mag,datestr(cata_table_i.DateTime,'HH:MM:ss')};
%             superTitle(sprintf('Earthquake Properties: dep = %.1f km; ML = %.1f; time = %s',cell4sprintf{:}),...
%                 'TextOption',TextOption2,'TextPosition',TextPosition2);

            print(fullfile(figpDir_prb,sprintf('Probability_all(%.3d).png',probFigNum)),'-dpng','-r350'); 
            probFigNum=probFigNum+1;
            close;


            figure;
            sbi = 1;

        end
    end
    whiteborder(figpDir_prb,'LeftRight',125,'SaveInplace',1);
%     end
    
end
    









% cataM1 = sortrows(cataM,'DateTime','ascend'); notice that cataM should
% not be used in this section, since it preserves only that of the last
% model in RankedModelsBestRand.

fprintf('catalog is filtered using Mc = %.1f and Rc = %.1f\n',Mcfixed,Rcfixed);

end

%% Test EQK (try to use xy2ij() to check it.)
if settings_cwb.do_Plot % Test EQK
if ~exist('Probability','var') || ~exist('Summary','var')
    Probability = only1field(fullfile(configs.dir_EQK_probability,'Probability.mat'));
    Summary_tb = only1field(fullfile(configs.dir_EQK_probability,'Summary.mat'));
    cataM_j = only1field(fullfile(configs.dir_EQK_probability,'cataM.mat'));
    tmSeq = only1field(fullfile(configs.dir_EQK_probability,'tmSeq.mat'));
    disp('Probability/Summary/...etc. loaded.');
end


noTest = 5; % number of saved TIP and EQK, for testing only.
climit = [0,1]; % needs attention
for i = 1:noTest
    EQK = Summary_tb.EQK{i};
    ind1 = find(~isnan(EQK)&EQK~=0);
    [~,~,EQT_ind] = ind2sub(size(EQK),ind1);
    
    for j = 1:length(EQT_ind)
        Ti = EQT_ind(j);
        C = EQK(:,:,Ti);
        figure;
        imagesc(TwLonLim,TwLatLim,C);
        hold on
        county_plot;
        today1 = tmSeq(Ti);        
        catatmp = EQinRange(CWBcatalogM5,...
                'PlotEpicenter',{'regular','monocolor','MarkerEdgeColor','b'},...
                'TimeRange',[today1,today1 + days(1)]);
        ax = gca;
        ax.YDir = 'normal';
        colorbar;
        ax.CLim = climit; % or caxis(climit)
        set(gcf,'Position',[-817.4000000000001,967.4000000000001,560,420]);
        close;

    end
end
end
%% GEMSTIP Joint station method - See EQK or TIP (TIP in 3D)
if settings_cwb.do_Plot
ModelBreak = 1;
pngname = 'TIP3DSample';
savefigTIP3D = fullfile(configs.dir_save_figures,'TIP3D'); mkdir(savefigTIP3D);
StList_loadMolScore = StationLocation_tb.Row;
skipstation = {'KM'};%{'KM','MS'};%{'KM','PT','CS','MS'};
[Lia,Locb] = ismember(skipstation,StList_loadMolScore);
StList_loadMolScore(Locb) = [];
StList_selected = StList_loadMolScore;
NoSt2 = length(StList_selected);
list_tsAIN_path = datalist('*tsAIN*',configs.dir_tsAIN);
NoF = size(list_tsAIN_path,1);
noTest = 5; % number of saved TIP and EQK, for testing only.
% dS = 0.1; % degree;
dT = 1;% day
dM = 6; % forecast duration in months expanded after one iteration.
plot_x = {TIP_time.range_train}; % the first range is the train period.
plot_x_Tags = sprintf("trn'%s",datestr(TIP_time.range_train(2),'yymmdd')); % string array
doit_JSt = true;
incfactor = 1;

while doit_JSt
    t_tomorrow = TIP_time.range_forecast(1);
    frc1 = TIP_time.range_forecast(1) + incfactor*calmonths(dM); incfactor = incfactor +1;
    frcRange = [t_tomorrow;min([frc1,TIP_time.range_forecast(2)])];
    TRangeTag = sprintf("frc'%s",datestr(frcRange(2),'yymmdd'));
    plot_x = [plot_x,{frcRange}];
    plot_x_Tags = [plot_x_Tags,TRangeTag]; % string array
    if frc1>=TIP_time.range_forecast(2)
        doit_JSt = false;
    end
end
numelfrctags = length(plot_x_Tags);

paths_MolchanX_trn = datalist(sprintf('MolchanScore_*%s',TIP_time.tag_train),configs.dir_dataderived);
NofreqBand = size(paths_MolchanX_trn,1);
if NofreqBand>4 % freqBand
    winopen_alt(configs.dir_dataderived);
    error('please check if there are superfluous folders.');
end



for i = 1:NofreqBand
    pmi = paths_MolchanX_trn.fullpath{i};
    [RankedModels,RankedModelsBestRand] = MolchanScore_load(BestN,nModels_Comb,pmi,StList_selected);

    freqBand = RankedModels.Tag;
    pathlist_tsAIN = datalist(sprintf('tsAIN*%s*',freqBand),configs.dir_dataderived);  
    if size(pathlist_tsAIN,1)~=1
        winopen_alt(configs.dir_dataderived);
        error('There is no corresponding tsAIN folders.');
    end
    pti = pathlist_tsAIN.fullpath{1};

    for Rng_i = 1

        truncatedRange = plot_x{Rng_i};
        tmBeg = min(truncatedRange);
        tmEnd = max(truncatedRange);
        tmSeq = [tmBeg:days(dT):tmEnd]'; % datetime array in forecast range
        [~,~,last_EQK,last_TIP,Summary2] = TIPs_JointStation(tmSeq,...
            CWBcatalog,LatLons,RankedModels,pti,...
            'ReturnAfter',{'Step',4,'Model',ModelBreak});
        EQK = last_EQK;
        TIP = last_TIP;
        Xc = Summary2.XCordinate;
        Yc = Summary2.YCordinate;
        Zc = 1:size(TIP,3);
        
        
        % prepare for plot station location and detection radius
        NoStse = length(StList_selected);
        R_deg_list = NaN(NoStse,1);
        LatLon_list = NaN(NoStse,2);
        fieldSt ='Station';
        G_table = table;
        St_table = table(StList_selected,'VariableName',{fieldSt});
        for st = 1:NoStse
            StNmX = St_table{st,1};
            R_km = RankedModels.(StNmX{1}).Rc(ModelBreak);
            R_deg_list(st) = km2deg(R_km);
            LatLon_list(st,:) = LatLons.(StNmX{1});
            tmp_tb = RankedModels.(StNmX{1})(ModelBreak,:);
            G_table = [G_table;tmp_tb];
        end
        
        % write to excel (the parameter sets used in this example)
        exPath = table2excel(G_table,'Folder',configs.dir_save_figures,...
            'File',sprintf('ExampleJointStation_%s',freqBand),...
            'Option',{'Sheet',1,'Range','B1'});
        writetable(St_table,exPath,...
            'Sheet',1,'Range','A1');

        
        

        
        % plot slice of EQK or TIP 
        [X,Y,Z]=meshgrid(Xc,Yc,Zc);
        xslice = []; yslice = []; % no slice on x and y.
%         zslice= [1:10:size(TIP,3)]; mapZ = Zc(1);
        gridZ = 800; zslice = gridZ:1000; mapZ = 730;
%         zslice= [5:15];%[size(TIP,3)]; mapZ = 5;
        
        

        
        figure;
%         scatter3FromArray(XLim4Col,YLim4Row,array3d);
        slc = slice(X,Y,Z,TIP,xslice,yslice,zslice);
        hold on
        for sl = 1:length(slc)
%             slc(sl).FaceAlpha = 0.4;   
                slc(sl).EdgeColor = 'none';    
        end
%         slc(1).EdgeColor = 'w'; % grid in the 1st layer.
%         slc(1).EdgeAlpha = 0.3;
  

        h = get(gca,'DataAspectRatio');
        
        mapplot('Function','plot3','Z',mapZ,'Options',{'LineWidth',1.5});%,'LatLim',TwLatLim,'LonLim',TwLonLim);
%         mapplot('Function','patch','Options',{'LineWidth',1.5,'FaceColor','w','FaceAlpha',0.8});%,'LatLim',TwLatLim,'LonLim',TwLonLim);

        xlim(TwLonLim); ylim(TwLatLim);

        set(gca,'DataAspectRatio',[1,1,h(3)]);
        ax = gca;
        ax.CameraPosition = [134.7964067301965,5.506102506132994,49668.1132612974];
        ax.CameraViewAngle = 10.830799783967324;       
        ax.View = [54.9000 51.8678];
        ax.Position = [0.1300    0.1100    0.7750    0.8150];
        ax.ZDir = 'reverse';
        set(gcf,'Position',[-842.2000  259.4000  800.8000  747.2000]);
        clrbar = colorbar;
        clrbar.Ticks(2:end-1) = [];% preserve only labels '0' and '1'.
        colormap(flipud([1,1,0;0,0.7,1]));
        clrbar.Position = [0.2073    0.8403    0.0265    0.054];
        clrbar.Title.String = 'TIP';
        plotGridFromArray(TwLonLim,TwLatLim,TIP(:,:,gridZ)','Z',gridZ,...
            'Options',{'EdgeColor','w','FaceColor','none'});
        plot3(StationLocation_tb.Lon,StationLocation_tb.Lat,mapZ*ones(size(StationLocation_tb.Lat)),...
            'b^','MarkerSize',6, 'MarkerFaceColor','b');
        circles3(LatLon_list(:,2),LatLon_list(:,1),mapZ,R_deg_list,...
            'FaceColor','none','EdgeColor',[1,0,0],'EdgeAlpha',0.4,'LineWidth',1.5);
%         title(freqBand,'Interpreter','none');
        title({'Time of Increased Probability'; '(joint station method)'});
        xlabel('Longitude');
        ylabel('Latitude');
        zlabel('days');
        ax.ZTickLabel = datestr(tmSeq(ax.ZTick));zlabel('date');
        print(fullfile(savefigTIP3D,sprintf('%s%s.png',pngname,freqBand)),'-dpng','-r250');
        close;
        
        L0 =EQK == 1 & TIP == 1;
        L1 = any(L0,[1,2]); % any along dimension 1 and 2
        L2 = find(L1==1);
        NoE = [100:120]';
        L2 = [NoE;L2]; % add several without earthquakes
        
        for l = 1:min([40,numel(L2)])
            dnum = L2(l);
            CWBl = EQinRange(CWBcatalogM5,'TimeRange',[tmSeq(dnum),tmSeq(dnum)+days(1)]);
            if size(CWBl,1)>1
                CWBl = CWBl(1,:);
            end
            figure;
            EQKTIP = TIP(:,:,dnum) + EQK(:,:,dnum);% = 2 if there is an earthquake.
            % but there might be some cells indicating earthquake but without alarm,
            % will be 1 (marked as TIP==1). 
            % MUST be fixed if you want to show EQK = 1 but TIP = 0 
            imc = imagesc(TwLonLim,TwLatLim,EQKTIP);
            imc.CData(isnan(EQKTIP)) = -1;
            mapplot('Options',{'LineWidth',0.5});
            clrbar2 = colorbar;
            colormap(flipud([1,0,0;1,1,0;0,0.7,1;1,1,1])); % Red,Yellow,Cyan,White
            caxis([-1.5,2.5]); % extend color limits 0.5 units.
            clrbar2.Ticks = [-1:2];
            clrbar2.TickLabels = {'非預報區','TIP=0','TIP=1','EQK=1'};
            
            if size(CWBl,1)>0
                EQKinfo= sprintf('地震時間: %s \n 規模: %.1f; 深度: %.1f km',...
                       datestr(CWBl.DateTime),CWBl.Mag,CWBl.Depth);
                lazy_annotation(gcf,EQKinfo,'Position',[0.1,0.82],'FontSize',8);
            else % no earthquake
                title(datestr(tmSeq(dnum)));
            end
            axis square
            ax2 = gca;
            ax2.YDir = 'normal';
            set(gcf,'Position',[23.4, 305.0, 268.0, 232.8]);
            print(fullfile(savefigTIP3D,sprintf('%s%s_sb(%.2d).png',pngname,freqBand,l)),'-dpng','-r250');
            close;

            % you may also try pcolor to plot NaN as no color.

%             EQKTIP = NaN(numel(Yc),numel(Xc),1);
%             [X2,Y2,Z2]=meshgrid(Xc,Yc,1);
%             imc = slice(EQKTIP,X2,Y2,Z2);
            
        end
        

    end
end
end
%% Export parameter combinations (for Joint Station Method)
if settings_cwb.do_JointStation

TopN = 10;
StList_loadMolScore = StationLocation_tb.Row;
skipstation = {'KM'};%{'KM','MS'};%{'KM','PT','CS','MS'};
[Lia,Locb] = ismember(skipstation,StList_loadMolScore);
StList_loadMolScore(Locb) = [];
StList_selected = StList_loadMolScore;
NoStse = length(StList_selected);
paths_MolchanX_trn = datalist('MolchanScore_*',configs.dir_dataderived);


tmSeq = TIP_time.range_train(1):1:TIP_time.range_train(2); 
for Mol = 1:size(paths_MolchanX_trn,1)
    pmi = paths_MolchanX_trn.fullpath{Mol};
    fdi = paths_MolchanX_trn.file{Mol};
    RankedModelTop10 = MolchanScore_load(TopN,'whatever_is_ok',pmi,StList_selected);
    tag_f = regexp(fdi,'(?<=tag\[).+?(?=\])','match','once');
    tag_t = regexp(fdi,'(?<=trn\[).+?(?=\])','match','once');
    exPath = fullfile(configs.dir_save_figures,sprintf('JointStaParam_%s_[%s].xls',tag_f,tag_t));
    ncol = 1;
    % prepare for plot station location and detection radius
    
    fieldSt ='Station';
    
    St_table = table(StList_selected,'VariableName',{fieldSt});
%     mdli = 1;
    for mdli = 1:BestN
        G_table = table;
        for st = 1:NoStse
            StNmX = St_table{st,1};
            tmp_tb = RankedModelTop10.(StNmX{1})(mdli,:);
            G_table = [G_table;tmp_tb];
        end

        % write to excel
    %     exPath = table2excel(G_table,'Folder',configs.dir_save_figures,...
    %         'File',sprintf('JointStaParam_%s_[%s]',tag_f,tag_t),...
    %         'Option',{'Sheet',1,'Range','B1'});
        Rng_head = sprintf('A%s',num2str(ncol));   
        Rng_G_table = sprintf('B%s',num2str(ncol+1));
        Rng_St_table = sprintf('A%s',num2str(ncol+1));
        ncol = ncol + BestN + 5;
        writetable(G_table,exPath,'Sheet',1,'Range',Rng_G_table);
        writetable(St_table,exPath,'Sheet',1,'Range',Rng_St_table);
        writematrix(sprintf('case %s',num2str(mdli)),exPath,'Sheet',1,'Range',Rng_head);
                  %sprintf('case %s：各測站擬合程度第%s名之參數組合',num2str(mdli),num2str(mdli))
    end
   
    freqBand = RankedModelTop10.Tag;
    pathlist_tsAIN = datalist(sprintf('tsAIN*%s*',freqBand),configs.dir_dataderived);  
    if size(pathlist_tsAIN,1)~=1
        winopen_alt(configs.dir_dataderived);
        error('There is no corresponding tsAIN folders.');
    end
    
    
    pti = pathlist_tsAIN.fullpath{1};
    if regexpi(tag_t,'full','once')
        TimeRng_full = [trn_0;forc_end];
        tmBeg = TimeRng_full(1); % 記錄點
        tmEnd = TimeRng_full(2); 
    else
        datetime_str = split(tag_t,'-');
        tmBeg = datetime(datetime_str{1},'InputFormat','yyyyMMdd');
        tmEnd = datetime(datetime_str{2},'InputFormat','yyyyMMdd');
    end
    tmSeq_Mol = [tmBeg:1:tmEnd]';
    [~,Summary0,EQK,TIP,Summary2] = TIPs_JointStation(tmSeq_Mol,...
       CWBcatalog,LatLons,RankedModelTop10,pti);
    Summary1 = tableSum(Summary0,'mean');
    
    stringcell0 = compose('case %.2d',1:TopN);
%     JointStation = [{'聯合測站法'};stringcell0';{'平均'}];
    JointStation = [stringcell0';{'平均'}]; % tags
    table_tmp = table(JointStation);
    table_1 = [table_tmp,Summary1];
    exPath2 = fullfile(configs.dir_save_figures,sprintf('JointStaScoreTop%s_%s_[%s].xls',num2str(TopN),tag_f,tag_t));
    writetable(table_1,exPath2,'Sheet',1,'Range','A1');
%     writecell(JointStation,exPath2,'Sheet',1,'Range','A1');
    save(fullfile(configs.dir_joint_station_vars,...
        sprintf('MolchanScoreTop%s_tag[%s]_trn[%s].mat',num2str(TopN),tag_f,tag_t)),'table_1');
    
end
end
%% Plot Joint Station Case 1 to Case 10
if settings_cwb.do_Plot % Plot Joint Station Case 1 to Case 10
    varlist = datalist('MolchanScoreTop*.mat',configs.dir_joint_station_vars,'Search','**');
    NoL = size(varlist,1);
    if ~exist('score_cb','var')
        error("please execute the section 'max score of Molchan_CB' first.");
    end
    for i = 1:NoL
        fnamei = varlist.name{i};
        tag_f = regexp(fnamei,'(?<=tag\[).+?(?=\])','match','once'); % tag freqency band
        tag_f2 = regexprep(tag_f,'filtered\_','');
        tag_t = regexp(fnamei,'(?<=trn\[).+?(?=\])','match','once'); % tag time range
        table_1 = only1field(varlist.fullpath{i});
        x = [1:size(table_1,1)]';
        figure;
        
        p1 = plot(table_1.MolchanAlarmedRate,'-o','MarkerFaceColor','auto');
        hold on
        p2 = plot(table_1.HitRate,'-o','MarkerFaceColor','auto');
        p3 = plot(table_1.MolchanScore,'-o','MarkerFaceColor','auto');
        p4 = plot(x,max(score_cb)*ones(length(x),1),'--','Color',p3.Color); % max(D_cb)
        lgdtext = {'Alarmed Rate ($\tau(G)$)','Hit Rate ($P_{hit} = 1 - \nu(G)$)',...
            'Fitting Degree ($d(G)$)','$D_{cb}^{max}$'};
        legend(lgdtext,'Location','eastoutside','Interpreter','latex');
        
        ax = gca;
        ax.XTick = x;
        ax.XTickLabel = table_1.JointStation;
        ax.XTickLabelRotation = 45;
        ax.YLim = [0,1];
        set(gcf,'Position',[ 100   100  730  390]);
        titlecell = {'Fitting Degree of Joint Station Parameter, ';...
                    sprintf('case 1 to 10, %s',tag_f2)};
%                     sprintf('case 1 to 10, %s, %s',tag_f2,tag_t)};
        title(titlecell);
        adjPlot('larger','thicker');
        pngname = sprintf('JstScore_Case1to10_%s_[%s].png',tag_f2,tag_t);
        print(fullfile(configs.dir_save_figures,pngname),'-dpng','-r200');
        close;
              
    end
   
end

%% plot Comparison of Molchan Score of different frequency bands.
% if settings_cwb.do_Plot%plot Comparison of Molchan Score of different frequency bands.
%  varlist = datalist('MolchanScoreTop*FullRange*.mat',configs.dir_joint_station_vars,'Search','**');
%     NoL = size(varlist,1);
%     AlarmRate = NaN(NoL,1);
%     HitRate = NaN(NoL,1);
%     Score = NaN(NoL,1);
%     negA = NaN(NoL,1);
%     posA = NaN(NoL,1);
%     negH = NaN(NoL,1);
%     posH = NaN(NoL,1);
%     negS = NaN(NoL,1);
%     posS = NaN(NoL,1);
%     lgd = cell(1,NoL);
%     xTickLabels = cell(NoL,1);
%     
%     for i = 1:NoL
%         
%         fnamei = varlist.name{i};
%         table_2 = only1field(varlist.fullpath{i});
%         tag_f = regexp(fnamei,'(?<=tag\[).+?(?=\])','match','once'); 
%         tag_f2 = regexprep(tag_f,'filtered\_','');
%         tag_t = regexp(fnamei,'(?<=trn\[).+?(?=\])','match','once'); % tag time range
%         AlarmRate(i) = table_2{'mean','MolchanAlarmedRate'};
%         negA(i) = AlarmRate(i) - min(table_2.MolchanAlarmedRate);% min(table_2.MolchanAlarmedRate(1:end-1));
%         posA(i) = max(table_2.MolchanAlarmedRate) - AlarmRate(i);
%         HitRate(i) = table_2{'mean','HitRate'};
%         negH(i) = HitRate(i) - min(table_2.HitRate); %min(table_2.HitRate(1:end-1));
%         posH(i) = max(table_2.HitRate) - HitRate(i); 
%         Score(i) = table_2{'mean','MolchanScore'};
%         negS(i) = Score(i) - min(table_2.MolchanScore); % min(table_2.MolchanScore(1:end-1));
%         posS(i) = max(table_2.MolchanScore) - Score(i);
%         xTickLabels{i} = tag_f2;
%         
%     end
%     
%         x2 = [1:NoL]';        
%         figure;
% %         plot(x2,AlarmRate);%,'-o','MarkerFaceColor','auto');
%         errorbar(x2,AlarmRate,negA,posA);
%         hold on
% %         plot(x2,HitRate);%,'-o','MarkerFaceColor','auto');
%         errorbar(x2,HitRate,negH,posH);
% %         plot(x2,Score);%,'-o','MarkerFaceColor','auto');
%         e3 = errorbar(x2,Score,negS,posS);
%         p4 = plot(x2,max(score_cb)*ones(length(x2),1),'--','Color',e3.Color); % max(D_cb)
%         ax = gca;
%         dum0 = x2(1)-0.5;
%         dum1 = x2(end)+0.5;
%         ax.XLim = [dum0,dum1];
%         ax.XTick = [dum0;x2;dum1];
%         ax.XTickLabel = [{''};xTickLabels;{''}];
%         ax.XTickLabelRotation = 45;       
%         lgdtext = {'Alarmed Rate ($\tau(G)$)','Hit Rate ($P_{hit} = 1 - \nu(G)$)',...
%             'Fitting Degree ($d(G)$)','$D_{cb}^{max}$'};
%         legend(lgdtext,'Location','eastoutside','Interpreter','latex');
%         adjPlot('larger','thicker');
%         print(fullfile(configs.dir_save_figures,sprintf('ScoreComparison(3freqband)_[%s].png',tag_t)),'-dpng','-r200');
% 
% end
