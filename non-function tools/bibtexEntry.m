%%
% bibpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\REVISION_2019-05-17-3\Ref_1.bib';
% texpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\REVISION_2019-05-17-3\main.tex';
%問題：使用JabRef直接對.bib檔案把期刊簡寫改成ISO的話，就會抓不到換行符。但是看起來兩者是一模一樣的(只是期刊簡寫後有句點)
% 但是上傳到overleaf，再下載下來解壓縮就沒問題

bibpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\EPL_0705\Ref_1.bib';
texpath = 'C:\Google THW\0MyResearch(No-Code)\義大利人交流\較舊版本\EPL_0705\epl-template.tex';

extractEntries = {'author','title','journal','editor','volume','publisher','year','pages'};%,'month','number'};
style = 'epl';
encodingIn = 'UTF-8';

%
filename = ['thebibliography_',style,'.txt'];


T = bibtex2table(bibpath,encodingIn,'CiteOrder',texpath,'Field',extractEntries);


[authors_cell] = authorAbbrev(T.author); % default ,'Style','epl'
T.author = authors_cell;
[clipboard_copied] = thebibliography(T,extractEntries,filename);


