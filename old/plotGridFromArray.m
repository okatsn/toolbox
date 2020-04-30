function [] = plotGridFromArray(XLim4Col,YLim4Row,array2d,varargin)
% plot rectangulars (grid) if array2d(Ri,Ci) is not NaN. 
p = inputParser;
addParameter(p,'Options',{'FaceColor','none'});
addParameter(p,'Color',0.5);
addParameter(p,'Z',0);

parse(p,varargin{:});
Z = p.Results.Z;
Options = p.Results.Options;
colorArray = p.Results.Color;
% YLim4Row = [21.5000   26.0000];
% XLim4Col = [118.0000  122.5000];
% array2d = ones(46,46);

[NoYR,NoXC] = size(array2d);
tickYR = linspace(YLim4Row(1),YLim4Row(2),NoYR);
tickXC = linspace(XLim4Col(1),XLim4Col(2),NoXC);
[ptYR,ptXC] = meshgrid(tickYR,tickXC);
inorder = [1,2,4,3];
Z1 = Z*ones(1,4);
% figure;
for Ri = 1:NoYR
    for Ci = 1:NoXC
        idr0 = Ri;
        idr1 = min(Ri+1,NoYR);
        idc0 = Ci;
        idc1 = min(Ci+1,NoXC);
        if idr0==idr1 || idc0==idc1 ||isnan(array2d(Ri,Ci))
            continue
        end
        Xtmp = ptXC(idr0:idr1,idc0:idc1);
        Ytmp = ptYR(idr0:idr1,idc0:idc1);
        fill3(Xtmp(inorder),Ytmp(inorder),Z1,colorArray,Options{:});
        hold on
    end
end

% 
% outputArg1 = array2d;
% outputArg2 = colorArray2d;
end

