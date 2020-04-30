function [clipboard_copied] = thebibliography(T,bibtexEntry,filename)

NoCi = size(T,1);

koe = 0;
% bibtexEntry = {'author','title','journal','editor','volume','publisher','year','pages'};%,'month','number'};


NoF = length(bibtexEntry);

fid = fopen(filename, 'w');
fprintf(fid, '\\begin{thebibliography}{0} \n'); 
fprintf(fid, ''); 


for i = 1:NoCi
    entry_i = T.content{i};
    type = regexpi(entry_i,'\w+(?=\{)','match','once'); % 後面接大括號的第一個單字
    citeTag_i = T.cite{i};
    if isempty(citeTag_i)
        continue
    end
    
    fprintf(fid, ['\\bibitem{',citeTag_i,'}\n']); 
    koe = koe +1;
%     S = struct();
    
    
    switch type
        case {'book','Book'}
            if ~isempty(T.author{i})
                bibtexEntry2 = {'author','title','editor','volume','publisher','year','pages'};%注意順序，順序很重要
                in_tex_entry = {'Name','Book','Editor','Vol'        ,'Publ'         ,'Year','Page'};                
            else
                bibtexEntry2 = {'editor','title','volume','publisher','year','pages'};%注意順序，順序很重要
                in_tex_entry = {'Editor','Book','Vol'        ,'Publ'         ,'Year','Page'};                
            end            
            
        case {'article','Article'}
            bibtexEntry2 = {'author','journal','volume','year','pages'};%注意順序，順序很重要
            in_tex_entry = {'Name'  ,'Review','Vol'        ,'Year','Page'};
        otherwise
            for j= 1:NoF               
                fj = bibtexEntry{j};
                Tji = T.(fj){i};
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
                
                if isempty(Tji)
                    continue
                end
                to_print = ['  \\',fj2,Tji, '\n'];
                fprintf(fid,to_print); 
            end
            continue
            
    end
    
    NoF2 = length(bibtexEntry2);
    for j= 1:NoF2
        fj = bibtexEntry2{j};
        Tji = T.(fj){i};
        if isempty(Tji)
            continue
        end

        to_print = ['  \\',in_tex_entry{j},Tji, '\n'];
        fprintf(fid,to_print); 
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

