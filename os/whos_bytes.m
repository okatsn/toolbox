function [memory_size, varargout] = whos_bytes(a_variable,varargin)
% gives the size of memory that a_variable occupied.
% whos_bytes(a): 
%     - return the size of a_variable in unit bytes.
% whos_bytes(a,'MB'): 
%     - return the size of a_variable in unit MegaBytes, 
%     - and print the message in the command window.

a1234b = a_variable;
S = whos('a1234b');
memory_size = S.bytes;
reciprocal1024 = 1/1024;

if nargin > 1
    var_unit = varargin{1};
    switch var_unit
        case 'KB'
            memory_size = memory_size*reciprocal1024;
        case 'MB'
            memory_size = memory_size*reciprocal1024^2;
        case 'GB'
            memory_size = memory_size*reciprocal1024^3;
        otherwise
            error('Invalid unit of memory size.');
    end
    fprintf('This variable has a size of %.4f %s',memory_size,var_unit);
end

end

