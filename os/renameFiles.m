function renameFiles(regexppattern,sprintfformat,oldpathlist,varargin)
% rename files in pathlist with characters/numbers captured by
% regexppattern formating into sprintfformat.
% Example, for file name '[Stat_thr=5]_Ts_D=5.34_r=1.00_Fc=1.00_Type=dry.mat', we have
%     regexppattern = '((?<=(thr|D|r|Fc|Type)=)(\d+\.?\d*|\w+))';
%     sprintfformat = '[Stat]_thr[%s]_D[%s]_r[%s]_Fc[%s]_Type[%s].mat';
%
%     renameFiles(regexppattern,sprintfformat,oldpathlist); 
%     - regexppattern for regexp using 'match':
%     
%     renameFiles(regexppattern,sprintfformat,oldpathlist,'names'); 
%     - regexppattern for regexp using 'names'.
%
%     Noted that 'names' or 'match' for specifying 
%     regexp method should always be the last argument.
%
% Example2, do datalist inside the renameFiles function:
%     targetfolder = 'F:\GeoMag (main)\CWBMagnetism_1';
%     renameFiles(regexppattern,sprintfformat,targetfolder);
%
%     newfoldername = 'CWBMagnetism_2'; 
%     renameFiles(regexppattern,sprintfformat,targetfolder,newfoldername);
%     - output the renamed files to '..\CWBMagnetism_2\..' 
%       instead of its original e.g. '..\CWBMagnetism_1\..'
%     - Noted that newfoldername must be the 4th arguments (i.e. varargin{1})

% future work: add support to regexp(...,'names');
regdo = 'match';
createnewfoldertree = false;
regout_is_struct = false; 
if nargin>3
    if strcmp(varargin{end},'names')
        regdo = 'names';
        regout_is_struct = true;
        varargin(end) = [];
    end
    
    if strcmp(varargin{end}, 'match')
        varargin(end) = [];
    end
    
    if ischar(varargin{1}) && isfolder(oldpathlist)
        newfoldername = varargin{1};
        createnewfoldertree = true;
        varargin(1) = [];
    end
    
end


p = inputParser;
addParameter(p,'Order',0);
addParameter(p,'FunctionHandle',@(old,new) copyfile(old,new));
addParameter(p,'Overwrite',false);
addParameter(p,'Delete',false);
% addParameter(p,'dirPattern','*'); % pattern for finding files. e.g. *.txt for all files end with '.txt'
parse(p,varargin{:});
Order = p.Results.Order;
fileoperation = p.Results.FunctionHandle;
to_delete = p.Results.Delete;
rearrange = false;
overwriteexistingfile = p.Results.Overwrite;


lenvars = length(regexp(sprintfformat,'%','match'));
skippedcount = 0;
skippedfiles = {};

if ~isequal(Order,0)
    rearrange = true;
    if lenvars ~= length(Order) || ~(isa(Order,'double')||isa(Order,'single'))
        error("'Order' must be 1d numerical with length equal to the number of variable to be formatted in sprintf.");
    end
end

switch class(oldpathlist)
    case 'cell'
        
    case 'char'
        if ~isfolder(oldpathlist)
            error('This is not a valid folder.');
        end
        fdir0 = oldpathlist;
        if createnewfoldertree
            rootfolderloc = length(strsplit(fdir0,filesep)); % location/level of the root folder in the full path.
%             [~,oldfoldername,~] = fileparts(fdir0);
            oldfolderstruct = datalist('*',fdir0,'Search','**FolderOnly').fullpath;
            disp('[renameFiles] Creating new folder tree...');
            for i = 1:length(oldfolderstruct)
                folder_i = oldfolderstruct{i};
                dirseries = strsplit(folder_i,filesep);
                dirseries{rootfolderloc} = newfoldername;
                mkdir(fullfile(dirseries{:}));
            end
        end
        oldpathlist = datalist('*',fdir0,'Search','**FileOnly').fullpath;
    otherwise
        error('unsupported types. oldpathlist has to be an cell array or a folder path.')
end
total_iters = size(oldpathlist,1);

if total_iters>5000
tic; H = timeLeft0(total_iters,'Renaming files...',5000);    
end

for i = 1:total_iters
    if total_iters>5000; [H] = timeLeft1(toc,i,H); end
    oldpath = oldpathlist{i};
    [fdir,fname,fext] = fileparts(oldpath);
    if createnewfoldertree
        fdirsplitted = strsplit(fdir,filesep);
        fdirsplitted{rootfolderloc} = newfoldername;
        fdir = fullfile(fdirsplitted{:});
    end
    
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
    if ~overwriteexistingfile && isfile(newpath) 
        continue
    end
    try
        fileoperation(oldpath,newpath);
    catch ME
        [fdir_err,fname_err,fext_err] = fileparts(oldpath);
        winopen(fdir_err);
        error("The file '%s' may be broken. [%s]",[fname_err,fext_err],ME.message);
    end
    if to_delete
        delete(oldpath);
    end
end
if total_iters>5000; delete(H.waitbarHandle); end

if skippedcount > 0
    headstr = sprintf('The following %d files not copied/renamed:',skippedcount);
    warning('%s\n',headstr,skippedfiles{:});
else
    disp('All files sucessfully renamed.');
end

try
    winopen_alt(fdir);
catch
    winopen_alt(pwd);
end
end

