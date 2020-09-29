function [M,gridX,gridY] = pointsInGrid(scatterX,scatterY,scalarC,gridX,gridY,M)
% count the points (specified by scatterX and scatterY, each an N by 1 array)
% in each grid as N, and do M = N*scalarC + M. If there exists NaNs in
% array M, a nan plus by a non-zero value v becomes v, not nan.
if isempty(scatterX)
    warning('Input X (1st argument) is empty. Return without any modification.');
    return
end

% if isdatetime(scatterX)
%     scatterX = datenum(scatterX);
%     % gridX = datenum(gridX);
% end
% if isdatetime(scatterY)
%     scatterY = datenum(scatterY);
%     % gridY = datenum(gridY);
% end
edges = {gridX, gridY};
[N,c] = hist3([scatterX(:),scatterY(:)],'Edges',edges);
% i don't know why the last bin of hist3 is outside the last edge.
N(:,end) = [];
N(end,:) = [];

gridCenterX = c{1};
gridCenterY = c{2};

gridCenterX(end) = [];
gridCenterY(end) = [];
if ~isequal(size(N),size(M))
    error('input 2d array M should have the same size as N.');
end

isvalue_N = logical(N);
nanId_M = isnan(M);
M(nanId_M) = 0;
M = N*scalarC + M;
M(nanId_M & ~isvalue_N) = NaN;

end

