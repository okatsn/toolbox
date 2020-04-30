function [keywords,varargout] = matchNerase(string1,match2,to_remove2)
% INPUT:
% % Requred: 1: 'string'; 2:'match'; 3: 'to_remove' (in regexp expression)
% % e.g. string = [Coulomb]timeseries(10000pt)
% % e.g. match = '(\(.+\))|(\[.+\])'; % match anything inside the [] or ().
% % e.g. to_remove = '(pt|\(|\)|\[)'; % then remove 'pt' or parenthesis or square brackets. 
% % then the output will be {'Coulomb'},{'10000pt'}
% 
% Parameters: 
% % 'str2','double'
% % attempt to convert string to numbers (using str2double)
A = regexp(string1,match2,'match'); % match match2
B = regexprep(A,to_remove2,''); % remove to_remove2
C = str2double(B);
isnanC = isnan(C);

keywords = B;

for i = 1:numel(B)
    if isnanC(i)
        % if is nan, do nothing
    else
        B{i} = C(i);
    end
end

kw2double = B;

if nargout ==2
    varargout{1} = kw2double;
end


end

