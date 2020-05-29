function renameFiles(regexppattern,sprintfformat,oldpathlist,varargin)
% rename files in pathlist with characters/numbers captured by
% regexppattern formating into sprintfformat.
% Example, for file name '[Stat_thr=5]_Ts_D=5.34_r=1.00_Fc=1.00_Type=dry.mat', we have
%     regexppattern = '((?<=(thr|D|r|Fc|Type)=)(\d+\.?\d*|\w+))';
%     sprintfformat = '[Stat]_thr[%s]_D[%s]_r[%s]_Fc[%s]_Type[%s].mat';
%     renameFiles(regexppattern,sprintfformat,oldpathlist);
    
% future work: add support to regexp(...,'names');
p = inputParser;
addParameter(p,'Order',0);
addParameter(p,'FunctionHandle',@(old,new) copyfile(old,new));
addParameter(p,'NewPath',0);
parse(p,varargin{:});
Order = p.Results.Order;
fileoperation = p.Results.FunctionHandle;
newpathlist = p.Results.NewPath;
rearrange = false;


lenvars = length(regexp(sprintfformat,'%','match'));
skippedcount = 0;
skippedfiles = {};

if ~isequal(Order,0)
    rearrange = true;
    if lenvars ~= length(Order) || ~(isa(Order,'double')||isa(Order,'single'))
        error("'Order' must be 1d numerical with length equal to the number of variable to be formatted in sprintf.");
    end
end

for i = 1:size(oldpathlist,1)
    oldpath = oldpathlist{i};
    [fdir,fname,fext] = fileparts(oldpath);
    regout = regexp(fname,regexppattern,'match');
    lenregout = length(regout);
    if lenvars ~= lenregout
        skippedcount = skippedcount + 1;
        skippedfiles = [skippedfiles;{fname}];
        continue
    end
    
    if rearrange
        regout = regout(Order);
    end
        
    newfname = sprintf(sprintfformat,regout{:});
    newpath = fullfile(fdir,newfname);
    fileoperation(oldpath,newpath);
end


if skippedcount > 0
    warning('Total %d files not copied/moved. See the following:\n',skippedcount);
    warning('%s',skippedfiles{:});
end

try
    winopen_alt(fdir);
catch
    winopen_alt(pwd);
end
end

