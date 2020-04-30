

function [previous_tocs,timeElapsed,timeLeft] = timeLeftEst(this_toc,previous_tocs,this_iter,total_iters)
% tic; previous_tocs = NaN(1,total_iter); %out of loop
% this_toc = toc;% in loop
previous_tocs(this_iter) = this_toc;
timeElapsed = this_toc;
iter_left = total_iters - this_iter;
timeLeft = nanmedian(diff(previous_tocs))*iter_left;
end

