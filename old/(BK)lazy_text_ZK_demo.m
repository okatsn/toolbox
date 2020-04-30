fig = figure;
subplot(331);
semilogy(logspace(1, 10));
ax1 = fig.CurrentAxes;
info = 'subplot1';
Loc = 'NW'; 
text_property = {'Fontsize', 12,...
                 'BackgroundColor', 'red'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax1, 'property', text_property);

subplot(332);
plot(linspace(1, 10));
ax2 = fig.CurrentAxes;
info = 'subplot2';
Loc = 'N';
text_property = {'Fontsize', 15,...
                 'BackgroundColor', 'm'};
lazy_text_ZK(info, 'Location', Loc, 'property', text_property);

subplot(333);
plot(linspace(1, 10));
ax3 = fig.CurrentAxes;
info = 'subplot3';
Loc = 'NE';
text_property = {'Fontsize', 8,...
                 'BackgroundColor', 'm'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax3, 'property', text_property);

subplot(334);
plot(linspace(1, 10));
ax4 = fig.CurrentAxes;
info = 'subplot4';
Loc = 'W';
text_property = {'Fontsize', 6,...
                 'BackgroundColor', 'm'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax4, 'property', text_property);

subplot(335);
semilogy(linspace(1, 10));
ax5 = fig.CurrentAxes;
info = 'subplot5';
Loc = 'C';
text_property = {'Fontsize', 18,...
                 'BackgroundColor', 'g'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax5, 'property', text_property);

subplot(336);
semilogy(linspace(1, 10));
ax6 = fig.CurrentAxes;
info = 'subplot6';
Loc = 'E';
text_property = {'Fontsize', 12,...
                 'BackgroundColor', 'g'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax6, 'property', text_property);

subplot(337);
semilogy(linspace(1, 10));
ax7 = fig.CurrentAxes;
info = 'subplot7';
Loc = 'SW';
text_property = {'Fontsize', 12,...
                 'BackgroundColor', 'g'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax7, 'property', text_property);

subplot(338);
semilogy(linspace(1, 10));
ax8 = fig.CurrentAxes;
info = 'subplot8';
Loc = 'S';
text_property = {'Fontsize', 12,...
                 'BackgroundColor', 'y'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax8, 'property', text_property);

subplot(339);
semilogy(linspace(1, 10));
ax9 = fig.CurrentAxes;
info = 'subplot9';
Loc = 'SE';
text_property = {'Fontsize', 12,...
                 'BackgroundColor', 'm'};
lazy_text_ZK(info, 'Location', Loc, 'axis', ax9, 'property', text_property);