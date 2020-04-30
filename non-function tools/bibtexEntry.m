%%
% bibpath = 'C:\Google THW\0MyResearch(No-Code)\�q�j�Q�H��y\���ª���\REVISION_2019-05-17-3\Ref_1.bib';
% texpath = 'C:\Google THW\0MyResearch(No-Code)\�q�j�Q�H��y\���ª���\REVISION_2019-05-17-3\main.tex';
%���D�G�ϥ�JabRef������.bib�ɮק���Z²�g�令ISO���ܡA�N�|�줣�촫��šC���O�ݰ_�Ө�̬O�@�Ҥ@�˪�(�u�O���Z²�g�ᦳ�y�I)
% ���O�W�Ǩ�overleaf�A�A�U���U�Ӹ����Y�N�S���D

bibpath = 'C:\Google THW\0MyResearch(No-Code)\�q�j�Q�H��y\���ª���\EPL_0705\Ref_1.bib';
texpath = 'C:\Google THW\0MyResearch(No-Code)\�q�j�Q�H��y\���ª���\EPL_0705\epl-template.tex';

extractEntries = {'author','title','journal','editor','volume','publisher','year','pages'};%,'month','number'};
style = 'epl';
encodingIn = 'UTF-8';

%
filename = ['thebibliography_',style,'.txt'];


T = bibtex2table(bibpath,encodingIn,'CiteOrder',texpath,'Field',extractEntries);


[authors_cell] = authorAbbrev(T.author); % default ,'Style','epl'
T.author = authors_cell;
[clipboard_copied] = thebibliography(T,extractEntries,filename);


