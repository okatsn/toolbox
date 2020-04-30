% CSV read and save

%% Write
cd  'D:\Users\HSI\GoogleDrive_tsung_hsi\1研究\MATLAB\demo_script'
Y = [linspace(1,10,10); linspace(11,20,10); linspace(21,30,10)];
target_dir = fullfile(pwd,'test.txt');

dlmwrite(target_dir,Y,'delimiter', '\n'); %以換行為分隔值
% delimiter: '\t' '\n' ';' ','(default)

M = magic(5);
target_dir = fullfile(pwd,'test2.txt');
dlmwrite(target_dir,M); 

%% Read
M2 = csvread(target_dir); % works only for delimeter is ','

dlmwrite(target_dir,M,'delimiter', '\t');% produce tab-delimited files.
M3 = dlmread(target_dir,'\t'); % if delmiter is not ',', use dlmread

%% if csv contains string, see 'textscan', 'fscanf', 'xlsread', 'readtable' along with 'fopen'.
