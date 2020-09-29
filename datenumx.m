function varargout = datenumx(varargin)
% Compute datenum for multiple input at once.
%  e.g. [dn1,dn2,...] = datenumx(dt1,dt2,...);
% Support some datenum options, for example:
%       [dn1,dn2,...] = datenumx(dtStr1,dtStr2,...,'yyyymmdd');
if nargin>nargout
    datenum_option = varargin(nargout+1:end);
else
    datenum_option = {};
end
varargout = cell(1,nargout);

for i = 1:nargout
    varargout{i} = datenum(varargin{i},datenum_option{:});
end
end