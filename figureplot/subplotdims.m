% Given a integer `tableheight`, `[sbm, sbn] = subplotdims(tableheight)`
% for `subplot(sbm, sbn, i)`.
function [sbm, sbn] = subplotdims(tableheight)
    heightTime = tableheight;
    sbn = ceil(sqrt(heightTime));
    sbm = ceil(heightTime/sbn);
end