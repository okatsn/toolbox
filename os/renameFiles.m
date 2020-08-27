function renameFiles(regexppattern,sprintfformat,oldpathlist,varargin)
% rename files in pathlist with characters/numbers captured by
% regexppattern formating into sprintfformat.
% Example, for file name '[Stat_thr=5]_Ts_D=5.34_r=1.00_Fc=1.00_Type=dry.mat', we have
%     regexppattern = '((?<=(thr|D|r|Fc|Type)=)(\d+\.?\d*|\w+))';
%     sprintfformat = '[Stat]_thr[%s]_D[%s]_r[%s]_Fc[%s]_Type[%s].mat';
%     regexppattern for regexp using 'match':
%         renameFiles(regexppattern,sprintfformat,oldpathlist); 
%     regexppattern for regexp using 'names':
%         renameFiles(regexppattern,sprintfformat,oldpathlist,'names'); 
    
% future work: add support to regexp(...,'names');
if nargin>3 && strcmp(varargin{1},'names')
    regdo = 'names';
    regout_is_struct = true;
else
    regdo = 'match';
    regout_is_struct = false;
end

p = inputParser;
addParameter(p,'Order',0);
addParameter(p,'FunctionHandle',@(old,new) copyfile(old,new));
addParameter(p,'Delete',false);
parse(p,varargin{:});
Order = p.Results.Order;
fileoperation = p.Results.FunctionHandle;
to_delete = p.Results.Delete;
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
    fname_ext = [fname,fext];
    regout = regexp(fname_ext,regexppattern,regdo);
    if regout_is_struct
        regout = fieldvalues(regout);
    end
    
    
    lenregout = length(regout);
    if lenvars ~= lenregout
        skippedcount = skippedcount + 1;
        skippedfiles = [skippedfiles;{fname_ext}];
        continue
    end
    
    if rearrange
        regout = regout(Order);
    end
        
    newfname = sprintf(sprintfformat,regout{:});
    newpath = fullfile(fdir,newfname);
    fileoperation(oldpath,newpath);
    if to_delete
        delete(oldpath);
    end
end


if skippedcount > 0
    headstr = sprintf('The following %d files not copied/moved:',skippedcount);
    warning('%s\n',headstr,skippedfiles{:});
end

try
    winopen_alt(fdir);
catch
    winopen_alt(pwd);
end
end

