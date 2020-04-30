%% fileparts/addpath
addpath(fullfile(fileparts(pwd),'demo_script'));

%% dir search
cd  'D:\Users\HSI\GoogleDrive_tsung_hsi\1研究\MATLAB\CWB_precursor'
target_folder = fullfile(pwd, '地磁資料');

% go through all the sub-folder to find all *.txt file.
dir_info = dir(fullfile(target_folder,'**','*.txt')); 
dir_info = dir(fullfile(fileparts(pwd),'**','*.txt')); % previous folder/ parent folder
% '*' match zero or more character, not include separator; 
% '**' further includes sparator, so it will go through all the subfolders.

% find all folders (only 1st level) in a folder
dir_info = dir(target_folder);
dir_info(~[dir_info.isdir])=[];%remove non-directories

% find all sub-directories
A = genpath(target_folder);
B = strsplit(A,';'); % B is a list of all sub-directories

%% if folder not exists then mkdir
save_to = 'folder1';
fn = fullfile(pwd,save_to);
if exist(fn, 'dir')
   warning('save to %s',save_to);
 else
    warning('folder "%s" not exist. Created one.',save_to);
    mkdir(fn);
end

%% save variables
save(target_dir,'O','-v7.3');% for variable larger than 2GB
save(target_dir,'O');

%% Copy file to another folder and rename

dir_list_re = datalist_v2('*.txt','folder1');
fpath = dir_list_re(:,4);
fname = dir_list_re(:,2);
folders = dir_list_re(:,1);
for i = 1:numel(fpath)
    new_folder = regexprep(folders{i},'folder1','folder1_rename');
    mkdir_if_not_exist(new_folder);
    new_name = [fname{i} '.txt'];
    copy_to = fullfile(new_folder, new_name);
    copyfile(fpath{i},copy_to);
end
