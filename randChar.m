function [outputchar] = randChar(numcharout,varargin)
% create an 1d array of random characters.
choosefrom = [char(48:57),char(65:90),char(97:122)];
% char(48:57): from 1 to 10
% char(65:90): from A to Z
% char(97:122)]: from a to z. See ASCII table.
id = randi([1,length(choosefrom)],1,numcharout);
outputchar = choosefrom(id);
end

