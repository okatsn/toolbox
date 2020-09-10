function [latitude_span_in_deg,longitude_span_in_deg] = km2latlon_rough(distance_in_km,around_what_latitude)
% This function convert kilometers to longitude differences
Re = 6371; %radius of earth
Rl = Re*cosd(around_what_latitude); % approx. radius of the slice of earth at the input latitude ('around_what_latitude').
latitude_span_in_deg = km2deg(distance_in_km,'earth'); %360*distance_in_km/(2*pi*Re);
longitude_span_in_deg = arrayfun(@(R,Lat) km2deg(R,Lat), distance_in_km, Rl); % 360*distance_in_km/(2*pi*Rl);
% there is also a km2rad

end

