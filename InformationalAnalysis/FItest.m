function [FI] = FItest(pdfx,x)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ps = pdfx;
qs = sqrt(ps);
FI = 4*sum(diff(qs));
end

