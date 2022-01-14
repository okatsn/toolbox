function [filepathnotrepeat] = pathnonrepeat(filepath,varargin)
% To prevent overwriting a existing file, 
% this function generate a new non-repeated file path if the file already exists.
%     
% How to use:
%     filepath = 'C:\Google THW\1MyResearch\DATA\data.mat';
%     [filepathnotrepeat] = pathnonrepeat(filepath);
fmt = ' (%.3d)';
filepathnotrepeat = filepath;
i = 0;
while isfile(filepathnotrepeat) || isfolder(filepathnotrepeat)
    i = i+1;
    ind = regexp(filepath,'\.');
    try
        pt = ind(end);
    catch
        pt = length(filepath) +1; % is folder
    end
    filepathnotrepeat = [filepath(1:pt-1), sprintf(fmt,i),filepath(pt:end)];
end


end

