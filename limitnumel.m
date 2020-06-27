function [better_less_than_this] = limitnumel(varargin)
% better_less_than_this = limitnumel(recommendFraction,vartype)
% better_less_than_this = maxnumel()
% better_less_than_this has been floored to be integer.
% Instruction:
% This function returns the recommended max number of elements in the array.
% For example, if output = 6e7, then it is better not to load/create a variable
% with its number of elements larger than this.
% - the recommended number of elements is 0.01*MaxPossibleArrayBytes for double precision (default).
% - This function relys on `memory`, which is available only on Windows.
% - For Linux or other OS, a fixed value of 6e7 will be returned.
% How to use:
% - better_less_than_this = maxnumel(); 
%     Largest number of elements for double-precision arrays in default, 
%     where the recommendFraction = 0.01 (default).
% - better_less_than_this = maxnumel(0.5,'single');
%     Largest number of elements for single-precision arrays in default, 
%     where the recommendFraction = 0.5.
recommendFraction = 0.01; % default
vartype = 'double';

if nargin > 0 
    recommendFraction = varargin{1};
    if nargin>1
        vartype = varargin{2};
    end
end



switch vartype
    case 'double'
        % max number of elements should be s.MaxPossibleArrayBytes*8/64,
        % where 8/64 = 0.125; For safty, I choose 0.01 to preserve rooms for
        % other variables.
    case 'single'
        recommendFraction = recommendFraction*2;
    otherwise
        error('Incorrect type name.');

end

if ispc
    s = memory;
    better_less_than_this = floor(s.MaxPossibleArrayBytes*recommendFraction);
else
    better_less_than_this = 6e7;
    warning('[limitnumel] this function do not support OS other than Windows. Return a fixed value of %.0e',better_less_than_this);
end


end

