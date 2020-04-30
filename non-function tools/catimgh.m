%% cat_img
% root_0 = 'C:\Google THW\1MyResearch\MATLAB';
% addpath(fullfile(root_0,'toolbox'));
% scriptDir = fullfile(root_0,'imageProcessing');
% tempImg = fullfile(scriptDir,'temp');
% cd(scriptDir);
Abbre = 5; % Abbreviation to n th character.
list = datalist('*',tempImg,'Search','FileOnly');
NoR = size(list,1);

imgcell = cell(1,NoR);
name_all = [];
for i = 1:NoR
    imgcell{i} = imread(list.fullpath{i});
    name_i = list.name{i};
    idx = min(Abbre,length(name_i));
    name_all = [name_all,'_',name_i(1:idx)];
end

[~,imhcat] = im2im(imgcell,'Height');%,'ForceOutput',1
fname = sprintf('Fig_%s.png',name_all);
fpath = [tempImg, filesep, fname];
imwrite(imhcat,fpath);

for i = 1:NoR
    movefile(list.fullpath{i},[tempImg, filesep, 'old']);
end

disp('Coversion complete');
clipboard('copy',fname); %copies data to the clipboard.
winopen(tempImg);