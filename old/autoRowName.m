function [table1] = autoRowName(table1,columnName,expr4regexp,varargin)
% autoRowName(table1,columnName,expr4regexp,varargin)
% use regexp to extract certain keywords from table1.columnName, and make
% them the RowNames of the table1.

% p = inputParser;
% addParameter(p,'regexpOption',{'match','once'});
% parse(p,varargin{:});
% regexpOption = p.Results.regexpOption;
% regexpOption = {'match','once'};
table1.Properties.RowNames = regexp(table1.(columnName),expr4regexp,'match','once');

end

