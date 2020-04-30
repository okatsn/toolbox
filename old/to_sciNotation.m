function [string2] = to_sciNotation(double_input,digits)
% e.g. double_input = 35000; digits = 3;
% convert number (double) to scientific notation string
if isa(double_input,'double')
    E1 = sprintf('%%.%de',digits);
    string1 = sprintf(E1,double_input);
    idx_e = regexp(string1,'e');
    string2 = [string1(1:idx_e-1) '\times10^{' string1(idx_e+1:end) '}'];
    
    %remove extra
    string2 = regexprep(string2,'1\\times',''); % e.g. 1x10^3 -> 10^3
    string2 = regexprep(string2,'\{\+0','{'); % e.g. 10^{+01} -> 10^{1}
    string2 = regexprep(string2,'\{\-0','{-'); % e.g. '10^{-04}' ->  '10^{-4}'
    
else
    string2 = double_input;
    warning('convert nothing, input has to be double');
end
%     assignin('base','string1',string1);
%     assignin('base','E1',E1);
%     assignin('base','digits',digits);
end

