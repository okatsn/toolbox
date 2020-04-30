%% findObj_Children
% gcf_1. + Tab to see its sub classes.

%% Basics; 1st level, the figure.
gcf_1 = gcf;
gcf_1.Number % for example, gcf_1.Number is 3 for figure (3).
gcf_1.Position % e.g. [158 1022 815 262] -> [xstart ystart width height]; 
% xystart is the position of bottom left point of the figure from the bottom left corner of the screen.
gcf_1.Units      % in unit 'pixels'

%% 2nd level, axes, legends and so on.
% right click on axes to open the property inspector.
gcf_1.Children % list the axes and legends of all subplots
ax = gcf_.Children.findobj('-regexp', 'Type', 'axes'); % find the children of gcf whose type named 'axes'.
% ax. + Tab to see the classes of the axes
ax(1).XLim 
ax(1).XScale      % 'linear' or 'log'
ax(1).Position   % [xstart ystart width height]; from the btm-left corner of the figure.
ax(1).Units        % could be 'pixels' or 'normalized'(btwn 0-1) and so on.

%% Rename the identifier of an axe and find it.
ax(1).Tag = 'TEX1'; 
gcf_.Children.findobj('-regexp', 'Tag', 'TEX1')

%% get the annotation
annotation('textbox',[0.5 0.5 0.3 0.3],'string','How are you','Tag','annotation');
% 'Tag','annotation' allows findall(gcf,'Tag','annotation'); 
% otherwise, annotation cannot be obtained.
a = findall(gcf_1,'Tag','annotation');
a(1).Position


