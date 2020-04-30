function [outputtable] = tableSum(inputtable,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
A = {'mean','sum','std'};
B = varargin;
% [Results,varargin] = inputParser2(varargin,A);
[Lia,Locb] = ismember(A,B); % find if element in A is in B. Lia: Logical index in A. Location in B.
extra = sum(Lia);

classtb = varfun(@class,inputtable);
isnumer = varfun(@isnumeric,inputtable);
isnumer_idx = table2array(isnumer);
varTyp = table2cell(classtb);
[~,n] = size(inputtable);
tableappend = table('Size',[extra,n],'VariableTypes',varTyp,...
    'VariableNames',inputtable.Properties.VariableNames,...
    'RowNames',A(Lia));
outputtable = [inputtable;tableappend];

for i = 1:numel(A)
    if Lia(i)
        switch A{i}
            case 'mean'
                tmp = nanmean(inputtable{:,isnumer_idx});
            case 'sum'
                tmp = nansum(inputtable{:,isnumer_idx});
            case 'std'
                tmp = nanstd(inputtable{:,isnumer_idx});
                
        end
        
        outputtable{A(i),isnumer_idx} = tmp;

    end
end
end

