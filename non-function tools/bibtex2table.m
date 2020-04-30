function T = bibtex2table(bibpath,encodingIn,varargin)

permission =  'r';
machinefmt = 'n';


p = inputParser;
addParameter(p,'CiteOrder',0,@(x) ischar(x));
addParameter(p,'Field',{});
parse(p,varargin{:});
R = p.Results;
texpath = R.CiteOrder;
bibtexEntry = R.Field;




%% Load .bib的
fileID =  fopen(bibpath,permission,machinefmt,encodingIn);
content = fscanf(fileID,'%c'); % c for any single character, including white space.
reg = regexp(content,'\n(?=@\w+\{)','split'); %split at linebreak(\n)  that is followed by '@somewords{'

NoR = numel(reg);
NoF = length(bibtexEntry);

varTypes = cell(1,NoF);
varTypes(:) = {'cell'};
T = table('Size',[NoR,NoF],'VariableTypes',varTypes,'VariableNames',bibtexEntry);

citeTagBib = cell(NoR,1);
expr_bib_citeTag = '(?<=@\w+\{).+?(?=,)'; %以'@xxx={' 開始，直到後面接第一個逗號結束
for i = 1:NoR
    entry_i = reg{i};
    citeTagBib{i} = regexpi(entry_i,expr_bib_citeTag,'match','once');
    
    
    for j = 1:NoF
        expr = sprintf('(?<=%s\\s*=\\s*)\\{.+?\\}(?=,?\n)',bibtexEntry{j}); %前面接 (xxx = ) 且結尾是 (, 換行符)
        % 最後一項會沒有逗號','
        
        field_j = regexpi(entry_i,expr,'match','once'); % +? is lazy mode.
        if isempty(field_j)
            continue
        end
        
        newstr = regexprep(field_j,'\\','\\\');
        % this will make '\&' to '\\&', for example, to avoid escaped
        % character error in fprintf.
        T.(bibtexEntry{j}){i} = newstr;
        
    end
    
    
end

% S = struct();
T.content = reg';
T.cite = citeTagBib;
% T = struct2table(S);

% reg0 = reg';


%% 掃描 tex 裡面的引用順序，並據此重排條目
if ~isequal(texpath,0) % then load .tex file to get citation order.
    
    fileID0 =  fopen(texpath,permission,machinefmt,encodingIn);
    content0 = fscanf(fileID0,'%c'); % c for any single character, including white space.
    citations = regexp(content0,'(?<=\\cite\{).+?(?=\})','match');% 貪婪模式：[A-Za-z0-9_,]+ 懶惰模式：[A-Za-z0-9_,]+?
    citations =  citations'; 

    out1 = cellfun(@(x) split(x,','),citations,'UniformOutput',false);
    citeTages = vertcat(out1{:});
    citeTagesOrdered = unique(citeTages,'stable'); % remove repeated ones but don't sort.

%     NoCi = length(citeTagesOrdered);
    % feature('DefaultCharacterSet', 'UTF8');
    



%% 重排條目(.bib的)(根據citeTagesOrdered)
    
    % expr_bib_citeTag = '(?<=@\w+\{)\s*\w+';
    


    [TorF,~] = ismember(citeTagBib,citeTagesOrdered);
    [~, idx] = ismember(citeTagesOrdered,citeTagBib(TorF));
%     reg = reg(TorF);
%     reg = reg(idx)';
T = T(TorF,:);
T = T(idx,:);


else
%     NoCi = NoR;

end


end