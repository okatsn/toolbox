function [b] = adjMultiply(a)
% multiplications of every two adjacent elements.
% That is, `for b(i) = a(i+1)*a(i); end`
% For example, a = [1,-2,5,3], then b will be [-2,-10,15].
a_iplus1 = a(2:end);
a_i = a(1:end-1);
b = a_iplus1.*a_i;
end

