function gifgo(fighandle,path_gif,iter,varargin)
% append frame to gif in a for loop.
% NOTICE: The first iteration has to be 1.
% example:
%     fighandle = figure;
%     for i = 1:10
%         plot(...);
%         drawnow;
%         gifgo(fighandle,path_gif,i)
%     end
p = inputParser;
addParameter(p,'imwriteOpt', {});
parse(p, varargin{:});
imwriteOpt = p.Results.imwriteOpt;

if isempty(imwriteOpt)
    imwriteOpt = {'DelayTime',0.1};
end


frame_i = getframe(fighandle);
im = frame2im(frame_i);
[imind,cm] = rgb2ind(im,256); 

if iter == 1 
  imwrite(imind,cm,path_gif,'gif', 'Loopcount',inf,imwriteOpt{:}); 
else 
  imwrite(imind,cm,path_gif,'gif','WriteMode','append',imwriteOpt{:}); 
end 

end

