function [img] = fig2im(varargin)
% convert figures to images (RGB). 
% img_cell=fig2im(fig1,[height1,width1],fig2,[height2,width2],fig3,[height3,width3],'dpi',300);
% [height1,width1] of the preceeding the figure is to set the Position of figure, and is optional.
% e.g. img=fig2im(fig1,fig2,[height2,width2],fig3) % gives image arrays of
% figure 1,3 (default size) and figure 2 (user defined size).
% This function depends on: insert1d.m.

dftRes = 200;

%% detect anything other than figure/position, copy to another variable and delete them in varargin
% WARNING: This must at the very first of the script
keylist = {'dpi'};
NoK = numel(keylist);
todo = false(1,NoK);
option_i = cell(1,NoK);
for i = 1:NoK
    keyword_at = strcmp(varargin,keylist{i});
    if any(keyword_at) % if true, do.
        idxtodel = find(keyword_at);
        option_i{i} = varargin{idxtodel+1};
        varargin(idxtodel:idxtodel+1) = []; % delete the option to prevent error
        todo(i) = true;
    else
        todo(i) = false;% do nothing, just don't export montage.
    end

end

if any(cellfun(@ischar,varargin)) % if there is still any strings in the varargin...
    errorStruct.message = 'Input error. Maybe you misspell something.';
    errorStruct.identifier = 'Custom:Error';
    error(errorStruct);
end

if todo(1)
    dftRes = option_i{1};
end


%%
idx_fig = cellfun(@(x) all(ishandle(x)),varargin); % index of figure objects.
NoF = sum(idx_fig); %number of figures.
Res_i= cell(1,NoF);

% assign scaling of each figures.
%     scale_i = ones(1,NoF); % N should equal to NoF.
Res_i = cellfun(@(x) sprintf('-r%d',dftRes), Res_i,'UniformOutput',false);
%% Settings

tmpDir = fullfile(pwd,'temp');
prefix = 'tmpfig_';
validpath(tmpDir,'mkdir');

% if nargin ==1 
%     f = varargin{1};
%     if ishandle(f)
%         file = fullfile(tmpDir,'tmp.png');
%         Res = sprintf('-r%d',dftRes);
%         print(file,'-dpng',Res);
%         img = imread(file);
%         delete(file);
%     else 
%         warning('must input at least one figure. output=0');
%         img = NaN;
%     end
% return
% end

xystart = [0,0];


%% Main function
inputcell = varargin;
user_defined_pos = cellfun(@(x) [xystart,x],inputcell(~idx_fig),'UniformOutput',false);
inputcell(~idx_fig) = user_defined_pos; % make [width,height] to [x0,y0,width,height].

% if diff is 0, then this one should be assigned a default position since the next one is also a figure.
dft_pos = diff(idx_fig); % but this don't take the end element into account.
if idx_fig(end) % if the end element is a figure, then it should also be assigned a default position.
    dft_pos = [dft_pos,0];
end
dft_pos = ~dft_pos; % makes 0->1; 1 or -1 -> 0
idx1 = find(dft_pos);

fig_with_default_pos = [varargin{idx1}];
default_pos = {fig_with_default_pos.Position};
inputcell2 = insert1d(default_pos,inputcell,idx1);

range1 = 1:2:2*NoF;

%%
k = 0;
img = cell(NoF,1);
for i = range1
    k = k+1;
    fi = inputcell2{i};
    set(fi,'Position',inputcell2{i+1});
    tmpf = fullfile(tmpDir,sprintf('%s%d.png',prefix,k));
%     Res = sprintf('-r%d',round(dftRes*scale_i(k)));
    print(fi,tmpf,'-dpng',Res_i{k});
    img{k} = imread(tmpf);
end


%% montage (1)

%% Force output width/height.


    delete(fullfile(tmpDir,[prefix,'*']));
    
    

end

