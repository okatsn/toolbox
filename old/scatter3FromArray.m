function [outputArg1,outputArg2] = scatter3FromArray(XLim4Col,YLim4Row,array3d)
% to scatter (This section is for scatter3.) See SOP_2019.m in
% CWB_precursor

[NoYR,NoXC,NoZD] = size(array3d);
Yc = linspace(YLim4Row(1),YLim4Row(2),NoYR);
Xc = linspace(XLim4Col(1),XLim4Col(2),NoXC);
Zc = 1:NoZD;
figure;
tc = flag; % colormap 'flag'
[row,col,dep] = ind2sub(size(array3d),1:numel(array3d));
ScatterX = Xc(col)';
ScatterY = Yc(row)';
ScatterZ = Zc(dep)';
SColor = NaN(length(ScatterZ),3);
ColorA = [1,0,0];
ColorB = [0,0,1];
ColorN = tc(2,:);
CAInd = find(array3d==1);
CBInd = find(array3d==0);
CNInd = find(isnan(array3d));
SColor(CAInd,:) = repmat(ColorA,length(CAInd),1);
%         SColor(CBInd,:) = repmat(ColorB,length(CBInd),1);
%         Ind2delete = CNInd;
Ind2delete = unique([CBInd;CNInd]);

SColor(Ind2delete,:) = [];
ScatterX(Ind2delete) = [];
ScatterY(Ind2delete) = [];
ScatterZ(Ind2delete) = [];
sc = scatter3(ScatterX,ScatterY,ScatterZ,ones(size(ScatterX)),SColor);
sc.MarkerEdgeAlpha = 0.5;
end

