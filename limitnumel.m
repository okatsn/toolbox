function [better_less_than_this] = limitnumel(varargin)
% Instruction:
% This function returns the recommended max number of elements in the array.
% For example, if output = 6e7, then it is better not to load/create a variable
% with its number of elements larger than this.
% - the recommended number of elements is 0.01*MaxPossibleArrayBytes for double precision (default).
% - This function relys on `memory`, which is available only on Windows.
% - For Linux or other OS, a fixed value of 6e7 will be returned.
% How to use:
% - better_less_than_this = maxnumel(); % for double-precision array in default.
% - better_less_than_this = maxnumel('single'); 
    
if nargin > 0 
    vartype = varargin{1};
else
    vartype = 'double';
end

switch vartype
    case 'double'
        recommendFraction = 0.01;
        % max number of elements should be s.MaxPossibleArrayBytes*8/64,
        % where 8/64 = 0.125; For safty, I choose 0.01 to preserve rooms for
        % other variables.
    case 'single'
        recommendFraction = 0.02;
    otherwise
        error('Incorrect type name.');

end

if ispc
    s = memory;
    better_less_than_this = round(s.MaxPossibleArrayBytes*recommendFraction);
else
    better_less_than_this = 6e7;
    warning('[limitnumel] this function do not support OS other than Windows. Return a fixed value of %.0e',better_less_than_this);
end


end

