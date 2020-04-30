function [clipboard_copied] = RefEntry(bibpath,varargin)
%%
% bibpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\REVISION_2019-05-17-3\Ref_1.bib';
% texpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\REVISION_2019-05-17-3\main.tex';


%%
% warning('接下來工作：依據.tex的引用順序(依序抓\citeXXX)更改(sort)引用排序')


p = inputParser;
addParameter(p,'Style','epl');
addParameter(p,'Encoding','UTF-8');
% addParameter(p,'OutputName','EPL.txt');
addParameter(p,'CiteOrder',0);
parse(p,varargin{:});
R = p.Results;
% filename = R.OutputName;
filename = ['thebibliography_',R.Style,'.txt'];

% if ~isequal(R.CiteOrder,0) % then load .tex file to get citation order.
    texpath = R.CiteOrder;
% end

switch R.Style
    case {'epl','EPL'}
        disp('convert bibtex to Europhysics ( EPL) style. Paste the result directly in the .tex file.');
        clipboard_copied = convert2epl(bibpath,texpath,R.Encoding,filename);
        
end



end

function [clipboard_copied] = convert2epl(bibpath,texpath,encodingIn,filename)
% epl_list =   { 'address','author','booktitle','chapter','edition','editor',...
%                         'howpublished','institution','journal','key','month','note','number','organization',...
%                         'pages','publisher','school','series','title','type','url','volume','year','eprint','SLACcitation' };

koe = 0;
permission =  'r';
machinefmt = 'n';


%% Load .bib的
fileID =  fopen(bibpath,permission,machinefmt,encodingIn);
content = fscanf(fileID,'%c'); % c for any single character, including white space.
reg = regexp(content,'\n(?=@\w+\{)','split'); %split at linebreak(\n)  that is followed by '@somewords{'

NoR = numel(reg);

reg0 = reg';


%% 掃描 tex 裡面的引用順序，並據此重排條目
if ~isequal(texpath,0) % then load .tex file to get citation order.
    fileID0 =  fopen(texpath,permission,machinefmt,encodingIn);
    content0 = fscanf(fileID0,'%c'); % c for any single character, including white space.
    citations = regexp(content0,'(?<=\\cite\{).+?(?=\})','match');% 貪婪模式：[A-Za-z0-9_,]+ 懶惰模式：[A-Za-z0-9_,]+?
    citations =  citations'; 

    out1 = cellfun(@(x) split(x,','),citations,'UniformOutput',false);
    citeTages = vertcat(out1{:});
    citeTagesOrdered = unique(citeTages,'stable'); % remove repeated ones but don't sort.

    NoCi = length(citeTagesOrdered);
    % feature('DefaultCharacterSet', 'UTF8');
    



%% 重排條目(.bib的)(根據citeTagesOrdered)
    citeTagBib = cell(NoR,1);
    % expr_bib_citeTag = '(?<=@\w+\{)\s*\w+';
    expr_bib_citeTag = '(?<=@\w+\{).+?(?=,)';

    for i = 1:NoR
        entry_i = reg{i};
        citeTagBib{i} = regexpi(entry_i,expr_bib_citeTag,'match','once');
    end
    [TorF,~] = ismember(citeTagBib,citeTagesOrdered);
    [~, idx] = ismember(citeTagesOrdered,citeTagBib(TorF));
    reg = reg(TorF);
    reg = reg(idx)';

else
    NoCi = NoR;

end





%% create thebibliography
%注意順序，順序很重要
bibtexEntry = {'author','title','journal','editor','volume','publisher','year','pages'};%,'month','number'};
% bit = {'Name'  ,'Editor','Book','journal','publisher','volume','number','pages','month','year'};

NoF = length(bibtexEntry);
fid = fopen(filename, 'w');
fprintf(fid, '\\begin{thebibliography}{0} \n'); 
fprintf(fid, ''); 


for i = 1:NoCi
    entry_i = reg{i};
    type = regexpi(entry_i,'\w+(?=\{)','match','once'); % 後面接大括號的第一個單字
    citeTag = regexpi(entry_i,expr_bib_citeTag,'match','once');
    if isempty(citeTag)
        continue
    end
    
    fprintf(fid, ['\\bibitem{',citeTag,'}\n']); 
    koe = koe +1;
    S = struct();
    for j = 1:NoF
        expr = sprintf('(?<=%s\\s*=\\s*)\\{.+?\\}(?=,\n)',bibtexEntry{j}); %前面接 (xxx = ) 且結尾是 (, 換行符)
        field_j = regexpi(entry_i,expr,'match','once'); % +? is lazy mode.
        if isempty(field_j)
            continue
        end
       
        
        newstr = regexprep(field_j,'\\','\\\');
        % this will make '\&' to '\\&', for example, to avoid escaped
        % character error in fprintf.
        S.(bibtexEntry{j}) = newstr;
    end
    
    switch type
        case {'book','Book'}
            if isfield(S,'author')
                bibtexEntry2 = {'author','title','editor','volume','publisher','year','pages'};%注意順序，順序很重要
                in_tex_entry = {'Name','Book','Editor','Vol'        ,'Publ'         ,'Year','Page'};                
            else
                bibtexEntry2 = {'editor','title','volume','publisher','year','pages'};%注意順序，順序很重要
                in_tex_entry = {'Editor','Book','Vol'        ,'Publ'         ,'Year','Page'};                
            end
            
            

            NoF2 = length(bibtexEntry2);
            for j= 1:NoF2
                fj = bibtexEntry2{j};
                if ~isfield(S,fj)
                    continue
                end
                
                to_print = ['  \\',in_tex_entry{j},S.(fj), '\n'];
                fprintf(fid,to_print); 
            end
            
            
        case {'article','Article'}
            bibtexEntry2 = {'author','journal','volume','year','pages'};%注意順序，順序很重要
            in_tex_entry = {'Name'  ,'Review','Vol'        ,'Year','Page'};
            NoF2 = length(bibtexEntry2);           
            for j= 1:NoF2
                fj = bibtexEntry2{j};
                if ~isfield(S,fj)
                    continue
                end
                to_print = ['  \\',in_tex_entry{j},S.(fj), '\n'];
                fprintf(fid,to_print); 
            end
        otherwise
            for j= 1:NoF
                fj = bibtexEntry{j};
                switch fj
                    case 'author'
                        fj2 = 'Name';
                    case 'volume'
                        fj2 = 'Vol';
                    case 'publisher'
                        fj2 = 'Publ';
                    case 'journal'
                        fj2 = 'Review';
                    case 'editor'
                        fj2 = 'Editor';
                    case 'year'
                        fj2 = 'Year';
                    case 'pages'
                        fj2 = 'Page';
                    otherwise
                        fj2 = fj;
                end
                
                if ~isfield(S,fj)
                    continue
                end
                to_print = ['  \\',fj2,S.(fj), '\n'];
                fprintf(fid,to_print); 
            end
            
    end
    
    
%     journal = regexpi(entry_i,'(?<=journal\s*=\s*)\{.+?\}','match','once');
%     volume = regexpi(entry_i,'(?<=volume\s*=\s*)\{.+?\}','match','once');
%     number = regexpi(entry_i,'(?<=number\s*=\s*)\{.+?\}','match','once');

    
end

fprintf(fid, '\\end{thebibliography}'); 
fclose(fid);

fid = fopen(filename, 'r'); %B = fread(fid,'*char'); NOT work properly.
clipboard_copied = fscanf(fid,'%c'); % c for any single character, including white space.
clipboard('copy',clipboard_copied); %copies data to the clipboard.
fclose(fid);


fprintf('total %d entries recorded',koe);


end