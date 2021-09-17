% `[nearest_idx_1,value_1,varargout] = nearest1d(array0,near_to)`
% find the element in array0 which is nearest to 'near_to'.
% 1st output: the index of the nearest element in array0.
% 2nd output: the values of the nearest elements in array0.
% value_1 = array0(nearest_idx_1);
% e.g [idx,val] = nearest1d(randn(100,1),[0.1,2,0.9])
function [nearest_idx_1,value_1,varargout] = nearest1d(array0,near_to)

if isempty(near_to)
    nearest_idx_1 = [];%false(size(array0));
    value_1 = [];
    return
end


SzArr = size(array0);
SzNr = size(near_to);
[MinSzNr,MinSzNrIdx] = min(SzNr);
[MinSzArr,MinSzArrIdx] = min(SzArr);

if MinSzNr >1 || MinSzArr > 1
    errorStruct.identifier = 'Custom:Error';
    errorStruct.message = 'Inputs must be one dimensional array (1 by N or N by 1 double)';
    error(errorStruct)
end

if MinSzNrIdx == 2 %make sure near_to is 1 by N array.
    near_to = near_to';
    SzNr = size(near_to);
    numelNr = SzNr(2);
else
    numelNr = SzNr(2);
end

if MinSzArrIdx == 1 % if minimum dimension of an array is row ()
    array0 = array0';
end


if numelNr>1
    array1 = repmat(array0,SzNr);
else
    array1 = array0;
end

near_to_1 = repmat(near_to,size(array0));
[dist,nearest_idx_1] = min(abs(minus(near_to_1,array1)));

if nargout>1
    value_1 = array1(nearest_idx_1);
    if nargout>2
        varargout{1} = dist;
    end
    
end
end

