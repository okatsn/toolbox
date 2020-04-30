
function add_scale(hAxes, axisStr, newLimits, newColor, newLabel)
% add a secondary tick labels along the same axis.
% see the link below:
% https://stackoverflow.com/questions/43867635/secondary-y-axis-in-matlab-3d-plot-surf-mesh-surfc

  % Get axis ruler to modify:
  axisStr = upper(axisStr);
  hRuler = get(hAxes, [axisStr 'Axis']);

  % Create TeX color modification strings:
  labelColor = ['\color[rgb]{' sprintf('%f ', hRuler.Label.Color) '}'];
  tickColor = ['\color[rgb]{' sprintf('%f ', hRuler.Color) '}'];
  newColor = ['\color[rgb]{' sprintf('%f ', newColor) '}'];

  % Compute tick values for new axis scale:
  tickValues = hRuler.TickValues;
  limits = hRuler.Limits;
  newValues = newLimits(1)+...
              diff(newLimits).*(tickValues-limits(1))./diff(limits);

  % Create new tick labels:
  formatString = ['\' tickColor hRuler.TickLabelFormat '\\newline\' ...
                  newColor hRuler.TickLabelFormat '\n'];
  newTicks = strsplit(sprintf(formatString, [tickValues; newValues]), '\n');

  % Update tick and axis labels:
  hRuler.Label.String = {[labelColor hRuler.Label.String]; ...
                         [newColor newLabel]};
  hRuler.TickLabels = newTicks(1:(end-1));

end