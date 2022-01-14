% `[eqdist] = simpleStationEQKdist3D(LatLonSt,LatLonEQK,DepthEQK)`
% calculate the distance between a station's location and the hypocenter 
% of the earthquake. It works fine only when the latitude is low, and the 
% earthquake-station distance isn't very large (e.g. <= 100 km).
% If depth doesn't matter, use `lldistkm`.
% 
% **Input Argument**:
% - `LatLonEQK`: The hypocenter of the earthquake, a 2 by 1 array being 
%   the location in latitude and longitude of the epicenter.
% - `DepthEQK`: The depth of the earthquake in unit kilometer.
% - `eqdist`: the approximation of the distance between the station and the
%   hypocenter.
function [eqdist] = simpleStationEQKdist3D(LatLonSt,LatLonEQK,DepthEQK)
arclendeg=distance('gc',LatLonSt,LatLonEQK);
arclenkm=deg2km(arclendeg);
eqdist=sqrt(arclenkm.^2+DepthEQK.^2);
end

