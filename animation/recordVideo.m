function [ F ] = recordVideo( frames )
%���X�����G�i�H���Animation_1��X
%�ϥΤ�k�G����recordVideo( frames )>��ʱ���3Dplot
%�W��frames=300
pause(1);
for i=1:frames
F(i)=getframe(gcf);
pause(0.02);
end


end

