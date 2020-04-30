function [O] = str2duration(inputchar,varargin)
% datestrFormat = 'yyyymmdd';
% datetimeFormat = 'yyyyMMdd';
% 
% if nargin==0
%     
% else
%     inputchar = varargin{1};
%     varargin(1) = [];
% end
    


p = inputParser;
addParameter(p,'datestrFormat',0);
addParameter(p,'datetimeFormat','yyyyMMdd');
% addParameter(p,'durationFormat','years');
parse(p,varargin{:});

datetimeFormat = p.Results.datetimeFormat;
datestrFormat = p.Results.datestrFormat;

% to_replace = regexp(datetimeFormat,'M+','match','once');
% if ~isempty(to_replace)
%     N_char = length(to_replace);
%     to_replace2 = 
%     datestrFormat = regexprep(datetimeFormat,to_replace2);
% end
% durationFormat = p.Results.durationFormat;
% O0 = regexp(inputchar,'(?<tag_0>\d+(?=\D))\D(?<tag_1>(?<=\D)\d+)','names'); % '\D' match character that is not a number
% O0 = regexp(inputchar,'(?<tag_0>\d+)\D(?<tag_1>\d+)','names'); % '\D' match character that is not a number
split_str = regexp(inputchar,'\D','split'); % '\D' match character that is not a number
% N_fmt = length(datetimeFormat);

N_dt = numel(split_str);
% dt = NaT(N_dt,1);

dt = datetime(split_str,'InputFormat',datetimeFormat);

dur = diff(dt);

O.datetime = dt;
O.duration = dur;
if ~isequal(datestrFormat,0)
    O.string = mat2cell(datestr(dt,datestrFormat),ones(1,N_dt));
end


% switch

% for i = 1:N_dt
%     i = 1;
%     str_i = split_str{i};
%     if length(str_i) ~= N_fmt
%         error('digits in string is not equal to the length of datetime Format.');
%     end
%     
%     
% 
% 
% end