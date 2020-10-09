function imageCollage(dir_datalist_png,path_out,sizeMbyN,varargin)
% Collage the images of 
% 1. all images in dir_png: 
%     imageCollage(dir_png,__);
% 2. all images specified by the datalist datalist_png: 
%     datalist_png = datalist(__);
%     imageCollage(datalist_png,__);
% to a specific size of M by N array until all images are consumed.
% The order of images is (default: fillDir = 1)
%      1   2   3
%      4   5   6
%      7   8   9
% for files in the datalist from 1 to 9.
%
% - 1st argument: a directory or a datalist from datalist(__)
% - 2nd argument: size of the array of images to become 1 large image collage.

fillDir = 1;

if ischar(dir_datalist_png) && isfolder(dir_datalist_png) % isfolder(<table>) raises error.
    datalist_png = [datalist('*.png',dir_datalist_png);...
                    datalist('*.jpg',dir_datalist_png);...
                    datalist('*.jpeg',dir_datalist_png)];
else
    datalist_png = dir_datalist_png;
end
pathlist = datalist_png.fullpath;

numtotalim = length(pathlist);
imRowCount = 0;
emptycellstofill = rem(numtotalim,prod(sizeMbyN));
pathlist = [pathlist;cell(emptycellstofill,1)];

sub_m = sizeMbyN(1);
sub_n = sizeMbyN(2);
pathlist_m = reshape(pathlist,sub_n,[]);
pathlist_m = pathlist_m';
numtotiter = size(pathlist_m,fillDir);

im_tot = [];

firstimage = imread(pathlist_m{1});
firstimgsize = size(firstimage);
whiteimg = 255 * ones(firstimgsize, 'uint8');
for i = 1:numtotiter
    imRowCount = imRowCount + 1;
    imgs_i = pathlist_m(i,:);
    imgs_i(cellfun(@isempty,imgs_i)) = {whiteimg};
    [~,im] = im2im(imgs_i,'Height');
    im_tot = vertcat(im_tot,im);    
    
    if imRowCount >= sub_m || i == numtotiter
        imRowCount = 0;
        imwrite(im_tot,pathnonrepeat(path_out));
        im_tot = [];
    end
end

end

