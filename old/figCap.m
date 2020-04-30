function [textout,varargout] = figCap(templatein,varNameList,varargin)
% figure caption
% input: 
%     Required: 
%         templatein = 'Figure %d The record of station %s with s=%.2f.....';
%         varNameList = {["PL";"YL";"MS"] ,[3.2, 1.5, 5.1] };
%               %element in each cell must be double array, string array or cell array.
%               %varNameList MUST be a cell array
%
%     Parameter:
%         'Range', [2:5,7,8]
%         
% output:
% 1. im % image matrix
% 2. formatted string array


p = inputParser;
addParameter(p,'Range',0);
addParameter(p,'Size',[800,200]);
addParameter(p,'FontSize',12);
parse(p,varargin{:});
r = p.Results;
fontSz = r.FontSize;

imSize = r.Size;
Rng = r.Range;

if isequal(Rng ,0)
    Rng = 1:numel(varNameList{1});
else
    Rng = r.Range;
end
numeltxout = numel(Rng);
numelArg = length(varNameList);

inputCell = cell(numeltxout,numelArg);

for i= 1:numelArg
    switch class(varNameList{i})
        case 'string'
            varNameList{i} = cellstr(varNameList{i});
        case 'double'
            varNameList{i} = num2cell(varNameList{i});
    end
    inputCell(:,i) = {varNameList{i}{:}}';
end

textout = cell(numeltxout,1);
for i = 1:numeltxout
    textout(i) = {sprintf(templatein,Rng(i),inputCell{i,:})};
end

if nargout >1
%     im = cell(numeltxout,1);
%     for i = 1:numeltxout
%         imi = whiteimage(imSize(1),imSize(2),'RGB');


        ftmp = figure;
        set(ftmp,'Position',[10,10,imSize])
        spaceInd = strfind(textout{1},' ');
        maxloops = length(spaceInd);
        linebreak = [];
        j =1;
        textout_1 = textout{1};
        for k= 1:maxloops
            
            ax1 = lazy_annotation(ftmp,textout_1(j:spaceInd(k)),'Position',[0,0.9],'FontSize',fontSz);
            pause(0.00001); % fuck matlab
            if ax1.Position(3) > 1
                linebreak = [linebreak,k-1];
                j = spaceInd(k-1) +1;
                delete(findall(ftmp,'type','annotation')); % or use clf
            end
        end
        close;
       
        NoL = length(linebreak);
        br = cell(1,NoL);
        br(:) = {'\n'};        
        f = cell(1,numeltxout);
        
        for i = 1:numeltxout
            
            f{i} = figure;
            set(f{i},'Position',[10,10,imSize]);
%             delete(findall(ftmp,'type','annotation')); % or use clf
%             linebreak = fliplr(linebreak);
            textout_i = textout{i};
            spaceInd = strfind(textout_i,' ');
%             ks = 1;
            if ~isempty(linebreak)
            textout_i = insert1d(br,textout_i,spaceInd(linebreak));
            end
            lazy_annotation(f{i},sprintf(textout_i),'Position',[0,1],'FontSize',fontSz);
            
%             for k = 1:
%                 textout_i = [textout_i(ks:linebreak(k))
%             end
        end
        
    im = fig2im(f{:});
%     end
    varargout{1} = im;
end

end

