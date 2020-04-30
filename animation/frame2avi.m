function [ output_args ] = frame2avi( A ,F )
%INPUT:
%F(i)=getframe(gcf);
%©Î·f°t [ F ] = recordVideo( frames )
if isstruct(A)
else
        clearvars A;
    A.finame='newAnimation.avi';
end

[~,frames]=size(F);
v=VideoWriter(A.finame,'Motion JPEG AVI');
open(v);

for i=1:frames
 writeVideo(v,F(i))
end
close(v);

end

