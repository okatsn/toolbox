function [eqdist] = simpleStationEQKdist3D(LatLonSt,LatLonEQK,DepthEQK)
% Simple function for calculating the distance between the station and
% the hypocenter.
% if you don't consider depth, use lldistkm.
arclendeg=distance('gc',LatLonSt,LatLonEQK);
arclenkm=deg2km(arclendeg);
eqdist=sqrt(arclenkm.^2+DepthEQK.^2);
end

