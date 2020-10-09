function [HMS] = S2HMS(S)
% Convert seconds in a day (1:86400) to N by 3 vector HMS
H = floor(S./3600);
MS = rem(S,3600);
M = floor(MS./60);
S = rem(MS,60);
HMS = [H,M,S];
end

