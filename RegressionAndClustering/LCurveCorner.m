function [index_corner, X_corner, Y_corner]=l_curve_corner(X,Y)
% this is a function that finds the corner of a L-shape curve
% geometrically. The code is majorly written by 
%             Parameter Estimation and Inverse Problems, 2nd edition, 2011
%             by R. Aster, B. Borchers, C. Thurber
%

%transform rho and eta into log-log space
x=log(X);
y=log(Y);
% x = X;
% y = Y;

% Triangular/circumscribed circle simple approximation to curvature 
% (after Roger Stafford)

% the series of points used for the triangle/circle
x1 = x(1:end-2);
x2 = x(2:end-1);
x3 = x(3:end);
y1 = y(1:end-2);
y2 = y(2:end-1);
y3 = y(3:end);

% the side lengths for each triangle
a = sqrt((x3-x2).^2+(y3-y2).^2);
b = sqrt((x1-x3).^2+(y1-y3).^2);
c = sqrt((x2-x1).^2+(y2-y1).^2);

s=(a+b+c)/2;%semi-perimeter

% the radius of each circle
R=(a.*b.*c)./(4*sqrt((s.*(s-a).*(s-b).*(s-c))));

% The curvature for each estimate for each value which is
% the reciprocal of its circumscribed radius. Since there aren't circles for 
% the end points they have no curvature
kappa = [0;1./R;0]; 
[~,index_corner]=max(abs(kappa(2:end-1)));

end
