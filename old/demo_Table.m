%% demoTable
NoC = 5; NoR=10;
varTypes = cell(1,5);
varTypes(:) = {'cell'};
cNms = {'fname','roiPair','namePair','bestSlope','bestPoint'};
T = table('Size',[NoR,NoC],'VariableTypes',varTypes,'VariableNames',cNms);

T.roiPair = cell(NoR,2);
T.fname = cell(NoR,1);
T.namePair = cell(NoR,2);

% table('Sz',[NoA,],'VariableNames',{},)

%% structure prelocation
NoC3 = 6; NoA = 5;
colNm3 =  {'DateNum','tsAIN_S','tsAIN_K','tsAIN_mu','tsAIN_V','Athr'};

struct_preloc = cell(1,2*NoC3);
struct_preloc(1:2:end) = colNm3;
struct_preloc(2:2:end) = cellfun(@(x) cell(1,NoA),struct_preloc(2:2:end),'UniformOutput',false);
AI = struct(struct_preloc{:});