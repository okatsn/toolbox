% load toolbox
root0 = 'D:\GoogleDrive';
% root0 = 'C:\Google THW';
shortcut = struct();
dir_matlab = fullfile(root0,'1Programming','MATLAB');
dir_toolbox = [dir_matlab filesep 'toolbox'];  
addpath(genpath(dir_toolbox)); %common and custom functions

shortcut.submission = fullfile(root0,'0MyResearch','(0)submission');
shortcut.cwb = fullfile(dir_matlab,'CWB_precursor');   
shortcut.sde = fullfile(dir_matlab,'TEX_fit_SDE_gen');
shortcut.gji20 = fullfile(shortcut.submission,'manuscript GJI 2020','matlab_script');
shortcut.gji20RupStat = fullfile(shortcut.gji20,'RuptureStatistics');
