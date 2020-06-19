function [YF] = adjAND(Y)
% applying AND operator on two adjacent elements.
% e.g. Y  = [1 0 0 1 1 1 0 1 0 0 1]
%      Y2 =  [0 0 0 1 1 0 0 0 0 0]
Y_iplus1 = Y(2:end);
Y_i = Y(1:end-1);
YF = and(Y_iplus1,Y_i);
end

