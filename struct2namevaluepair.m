function [varargin2] = struct2cell1d(p_Unmatched)

% p = inputParser;
% p.KeepUnmatched = true;
% addParameter(p,'ModifyTextExtent',0);
% parse(p,varargin1{:});
% recbox = p.Results.ModifyTextExtent;
% varargin2 = unmatched2cell(p.Unmatched);
names = fieldnames(p_Unmatched);
values = struct2cell(p_Unmatched);
nby2cellarray = [names,values];
varargin2 = reshape(nby2cellarray',1,[]);
end

