function [ F ] = recordVideo( frames )
%產出的結果可以丟到Animation_1輸出
%使用方法：執行recordVideo( frames )>手動旋轉3Dplot
%上次frames=300
pause(1);
for i=1:frames
F(i)=getframe(gcf);
pause(0.02);
end


end

