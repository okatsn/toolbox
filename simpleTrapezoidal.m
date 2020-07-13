function [Y,X] = simpleTrapezoidal(varargin)
% create an 1d array of trapezoidal shape (±è§Î) signal
% [Y,X] = simpleTrapezoidal(Xstart,XL0,XL1,TrapHeight,XR1,XR0,Xend,Xpoints);
%     XL0: the position (x) of the left-bottom of the trapezoid.
%     XL1: the position (x) of the left-top of the trapezoid.
%     XR1: the position (x) of the right-top of the trapezoid.
%     XR0: the position (x) of the right-bottom of the trapezoid.
Xpoints = 100;
if nargin >= 7
    if nargin == 8
        Xpoints = varargin{8};
    end
    Xstart = varargin{1};
    XL0 = varargin{2};
    XL1 = varargin{3};
    TrapHeight = varargin{4};
    XR1 = varargin{5};
    XR0 = varargin{6};
    Xend = varargin{7};
    
else
    error('Incorrect nargin');
    
end

X = linspace(Xstart,Xend,Xpoints);
Y = zeros(size(X));
Y(X<XR1 & X>XL1) = TrapHeight;
rampRid = X>=XR1 & X<=XR0;
lenrampRid = sum(rampRid);
Y(rampRid) = linspace(TrapHeight,0,lenrampRid);
rampLid = X>=XL0 & X<=XL1;
lenrampLid = sum(rampLid);
Y(rampLid) = linspace(0,TrapHeight,lenrampLid);


end

