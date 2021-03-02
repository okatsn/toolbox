function [ind_bestcorner] = kmean2findLcurvecorner(X)
% use kmean to find the corner of a L-shape curve.
% also see bvaluefit.

[nr, nc] = size(X);
if nc ~=1
    error("input X should be an N by 1 array.");
end

method = 'max';
largerthanmaxtimes = 50;

[Xs, I] = sort(X);
logXs = log(Xs);
clusteridx = kmeans(logXs,2); 

switch method
    case 'diff'
        splitpoints = find(diff(clusteridx)) + 1; 
        bestsplitpoints_id = ceil(length(splitpoints)/2); % Xs(bestcorner_id) is the corner.
        bestcorner_id = splitpoints(bestsplitpoints_id);
        ind_bestcorner = I(bestcorner_id); 
    case 'max'
        clustermax = sort([max(Xs(clusteridx==1)), max(Xs(clusteridx==2))]);
        ind_bestcorner = find(X>largerthanmaxtimes*clustermax(1),1);
end

end

