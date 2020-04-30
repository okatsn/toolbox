%% plot vertical line
hold on 
x0 = std(O.Y);
label1 = {'+1std','-1std','+2std','-2std','+3std','-3std'};
x1 = {x0,  -x0  ,2*x0  ,-2*x0  ,+3*x0,  -3*x0};
y1 = get(gca,'ylim');
for i = 1:numel(x1)
line([x1{i},x1{i}],y1,'Color','g');
text(x1{i},y1(2),label1{i},'Color','g','VerticalAlignment','top');
end