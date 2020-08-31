function [trueInd,falseInd] = splitContinue10(TF1dInd)
% separate the continuous true (1) or false (0).
% for example, isnanInd = [0 0 1 1 1 0 0 1 0 1];
% the output trueInd = {[3,4,5],[8],[10]}
%           falseInd = {[1,2],[6,7],[9]}

lenIndfull = length(TF1dInd);
CarteInd = 1:lenIndfull; % Cartesian (numbered indices)

diff_TF = diff(TF1dInd);
edges = find(diff_TF); % edges = [1,3] means splitting right after the 1st and 3rd element of TF1dind.

edges_ext = [0;edges;lenIndfull];
len_edges_ext = length(edges_ext);
C_all = cell(1,len_edges_ext-1);


for i = 2:len_edges_ext
    ind0 = edges_ext(i-1)+1;
    ind1 = edges_ext(i);
    seg_i = ind0:ind1;
    C_all{i-1} = seg_i;
end

if all(TF1dInd(C_all{1}) == 1)
    % first cell is all true
    trueInd = C_all(1:2:end);
    falseInd = C_all(2:2:end); % if C_all is only 1x1 cell, falseInd is empty.
else % == -1
    trueInd = C_all(2:2:end);
    falseInd = C_all(1:2:end);
end


end

