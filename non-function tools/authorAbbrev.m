function [authors_cell] = authorAbbrev(authors_cell,varargin)
p = inputParser;
addParameter(p,'Style','epl');
% particle = '(de|de la|der|van|von)';
% how about 'Don'?
%for particle see this: https://blog.apastyle.org/apastyle/author-names/

%% Author Acronym
% Initials after the surname: ��Author A.��, not ��A. Author��. % �m+�W(�Y)
% �V Multiple initials separated by spaces: ��Author A. B.��, not ��Author A.B.��
% �V Composite names with the dash: ��Author J.-Ph.��
% �V Authors separated with commas, last author separated with \and.
% Multiple initials separated by spaces: ��Author A. B.��, not ��Author A.B.��
% ���m��W�GInitials after the surname: ��Author A.��, not ��A. Author��.
% (Zotero ��Xbibtex ���ǬO���m��W)

% example: \Name{Author A., Author B. \and Author C.}


NoA = length(authors_cell);
authors_cell = regexprep(authors_cell,'(\{|\})','');% �M���Ҧ��j�A��
warningLog = {};

for i = 1:NoA % entry i
    fieldi = authors_cell{i};
    
    if isempty(fieldi)
        continue
    end
    
    ai = split(fieldi,' and ');
    disp(fieldi);
%     disp(ai);
        
    Noai = numel(ai);
    author_jF = cell(1,Noai);
    
    for j = 1:Noai % author j of entry i
        aij = ai{j};
        
%         if ~any(regexp(aij,particle))
            commaidx = regexp(aij,','); % �r�I�e���Osurname, ���n�Y�g
%             abbv = regexp(aij(commaidx+1:end),'(?<=[A-Za-z]*)-?[A-Z](?=[^\s]*)','match');
            abbv = regexp(aij(commaidx+1:end),'(?<=\w*)-?[A-Z](?=[^\s]*)','match');
            %�e���i�౵��A-Za-z�F�᭱���ۤ@�ǫD�ť���A�o�˪�A-Z(�@��)�A�j�g�r���e���i��]�t'-'
            % ĵ�i�A���r�Y���S��r��(�Ҧp'?str?m')���ӷ|�X��
            abbv = cellfun(@(x) [x,'.'], abbv, 'UniformOutput',0);
%         else
%             exprp = sprintf('%s\\s[A-Z][a-z]*',particle);
%             abbv = regexp(aij,exprp,'match');
%             abbv = cellfun(@(x) [x,'.'], abbv, 'UniformOutput',0);
%         end
        
        
%         author_j = regexp(ai{j},'[^, ]+','match'); % match all except space and comma.
        surname = regexp(aij,'[^,]*(?=\s?,)','match'); % match all except space and comma.
        
        author_jc = [surname,abbv];       
        tmp = strjoin(author_jc,' ');
        
        if j<(Noai-1)
            tmp = [tmp,','];
        end
        if j==Noai-1
            tmp = [tmp,' and'];
        end
        
        author_jF{j} = tmp;

    end    
    
    tmp2 = strjoin(author_jF,' ');
    authors_cell{i} = ['{',tmp2,'}']; %�[�^�j�A��
    disp(authors_cell{i});
    
    
    specialchar = any(regexp(tmp2,'[^[A-Za-z.`",\\\- 0-9]]'));%�S��r���G���OA-Za-z�r�I�M�Ʀr
    
    if specialchar
        warnmsg = sprintf('special character at entry %d (%s) \n',i,tmp2);
        warningLog = [warningLog; {warnmsg}];
        warning(warnmsg);
    end
    
    
end















end

