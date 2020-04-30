% e.g. 
% MatFile = matfile('G:\LongSDE\temp2.mat');
% inputXY = MatFile; 
% [Xs,Ys] = windowAverage(inputXY,'FieldName',{'fieldnameX','fieldnameY'})
function [XY] = windowAverage(inputXY,varargin)
funNm = 'windowAverage';
memoryLimit = 6e7; % the maximum data points to be loaded at once.
errorStruct.identifier = 'Custom:Error';
p = inputParser;
addParameter(p,'WindowWidth',100);
addParameter(p,'FieldName',0);
addParameter(p,'DeleteOriginal',false);
% addParameter(p,'Information',0);

parse(p,varargin{:});
result = p.Results;
AvgWindowWidth = result.WindowWidth;
delete_original = result.DeleteOriginal;
FieldName = result.FieldName;
% Frames = result.Frames;

% Information = result.Information;

avgDouble = false;
avgMatfile = false;
FieldName_default = {'X','Y'}; % if default name changed, MUST change the variable name in the code.
switch class(inputXY)
    case 'double'
%         error('Under Construction...');
        sizeinputXY = size(inputXY);
        maxsize = max(sizeinputXY);
        [NoV,minId] = min(sizeinputXY);
        WWidth = ceil(maxsize/AvgWindowWidth)*AvgWindowWidth;
        nanArray = NaN(WWidth- maxsize,1);
        if minId==1 % 1 or 2 by N
            inputXY = inputXY';           
        end
        XY= cell(1,NoV);
        mtf = struct();
        avgDouble = true;
        total_iter = 1;
        new_pt_per_iter = WWidth/AvgWindowWidth;  % rem must zero
        total_pts_after_avg = total_iter*new_pt_per_iter;
        for i = 1:NoV
            XY{i} = [inputXY(:,i);nanArray];
            mtf_new.(FieldName_default{i}) = NaN(total_pts_after_avg,1);
        end
    case {'matlab.io.MatFile','char'}
        if isequal(FieldName,0)
            errorStruct.message = "If input is matfile, then parameter 'FieldName' is required.";
            error(errorStruct);
        end
        
        if ischar(inputXY)
            mtf = matfile(inputXY);
            oldfilepath = inputXY;
            [filepath,fNm,fExt] = fileparts(oldfilepath);
            newfNm = sprintf('[WinAvg]%s%s',fNm,fExt);
        else
            mtf = inputXY;
            filepath = '';
            newfNm = '[WinAvg]____.mat';
        end
        
        if ischar(FieldName)
            FieldName = {FieldName};           
        end
        avgMatfile = true;
        [maxsize,maxdim] = max(size(mtf,FieldName{1})); %Use "size(mtf,'traceT')";  Don't use "size(mtf.traceT)"
        NoV = length(FieldName);
        WWidth = ceil(memoryLimit/AvgWindowWidth)*AvgWindowWidth;
        total_iter = ceil(maxsize/WWidth);
        nanArray = [];

        tic; H = timeLeft0(total_iter,funNm);
%         if maxsize/AvgWindowWidth > memoryLimit
%             warning('Memory may runs out in the end.')
%         end
        new_pt_per_iter = WWidth/AvgWindowWidth;  % rem must zero        
        total_pts_after_avg = total_iter*new_pt_per_iter;
        
        
        X = NaN(total_pts_after_avg,1);
        Y = X;
        
        newfullpath = fullfile(filepath,newfNm);
        [original_information] = matfileWhos(mtf);
        save(newfullpath,FieldName_default{1:NoV},'original_information','-v7.3');
        mtf_new = matfile(newfullpath,'Writable',true);
        
    otherwise
        errorStruct.message = "inputXY has to be 'double', 'matlab.io.MatFile', or filepath in 'char'.";
        error(errorStruct);
        
end

id0 = 1;
id1 = WWidth;
minid = 1;
nid0 = 1;
nid1 = new_pt_per_iter;
for J = 1:total_iter% id0<id1
    if avgMatfile
        [H] = timeLeft1(toc,J,H);
        XY = cell(1,NoV);
        if maxdim ==1
            for i = 1:NoV
                XY{i} = [mtf.(FieldName{i})(id0:id1,1);nanArray];
            end
        else %maxdim =2
            for i = 1:NoV
                XY{i} = [mtf.(FieldName{1})(1,id0:id1)';nanArray];
            end
        end
        
        
    end
    
    for i = 1:NoV
       tmpXY = reshape(XY{i},AvgWindowWidth,[]);
       tmpXYavg = nanmean(tmpXY,1);
       mtf_new.(FieldName_default{i})(nid0:nid1,1) = tmpXYavg';
    end
        
        
        
    if avgDouble    
        break % for input variable type as 'double', only the first loop is necessary.
    end
    
    % The following section only for input as matfile
    [id0,id1,minid,numelrem] = indexNext(id0,id1,WWidth,maxsize);
    if minid~=1 %last loop
        nanArray = NaN(numelrem,1);
    end
    [nid0,nid1,~,~] = indexNext(nid0,nid1,new_pt_per_iter,total_pts_after_avg);     
end
% The outputs of rem and mod are the same if the inputs have the same sign
try
    if delete_original
        delete(oldfilepath);
    end
    fprintf('Original File (%s) deleted. \n',fNm);
catch
    warning('Cannot delete file.')
end
end

function [id0,id1,minid,numelrem] = indexNext(id0,id1,points_per_loop,maxsize)
id0 = id0+points_per_loop;
tmpid1 = id1+points_per_loop;
[id1,minid] = min([tmpid1,maxsize]);
numelrem = tmpid1-maxsize;
end
