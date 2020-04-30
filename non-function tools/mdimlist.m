function [markdown_img_tag] = mdimlist(folderpath)
% list all images in a folder, output the img tag for markdown also copied
% to clipboard.
A = datalist('*',folderpath,'Search','FileOnly');
markdown_img_tag = sprintf('<img src="%s" > \n',A.file{:});
clipboard('copy',markdown_img_tag); %copies data to the clipboard.
end

