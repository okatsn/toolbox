[A, R] = geotiffread('C:\Google THW\1MyResearch\DATA\map\Taiwan_topography_20m\dem_20m.tif');

%%
for i = 1:2
  [XWLim(i),YWLim(i)] = utm2deg(R.XWorldLimits(i),R.YWorldLimits(i),'51 R');
  [XILim(i),YILim(i)] = utm2deg(R.XIntrinsicLimits(i),R.YIntrinsicLimits(i),'51 R');
%   https://zh.wikipedia.org/wiki/%E9%80%9A%E7%94%A8%E6%A8%AA%E8%BD%B4%E5%A2%A8%E5%8D%A1%E6%89%98%E6%8A%95%E5%BD%B1
end

R2 = R;
% R2.LatitudeLimits = YWLim;
% R2.LongitudeLimits = XWLim;
% R2.XIntrinsicLimits = XILim;
% R2.YIntrinsicLimits = YILim;
R2.XWorldLimits = YWLim;
R2.YWorldLimits = XWLim;
A2 = uint16(abs(A));
% mapshow(A2, R2);
axesm hatano
meshm(A2,R2);

zlimits = [min(A2(:)),max(A2(:))];
demcmap(zlimits);
colorbar;

%% ZK's work
m_proj('Transverse Mercator','lon', [YWLim(1), YWLim(2)], ...
       'lat',[XWLim(1), XWLim(2)]);
m_proj('get')
caxis([-300 1210]);  % 1210 chosen by manual adjustment
                     % since  'waterline" appears to be at about Z=2 (vertical datum for
                     % bathymetry is 'lowest normal tide')
colormap([m_colmap('blues',32); m_colmap('gland',128)]);
m_shadedrelief(linspace(YWLim(1), YWLim(2), R.RasterSize(2)), ...
               linspace(XWLim(1), XWLim(2), R.RasterSize(1)), flipud(double(A2)));
           