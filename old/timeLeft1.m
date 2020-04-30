% tic; H = timeLeft0(total_iters,functionNm)
% for i = 1:total_iters
%     [H] = timeLeft1(toc,i,H)
% end
% delete(H.waitbarHandle);
function [H] = timeLeft1(this_toc,this_iter,H)
% tic; H = timeLeft0()
% this_toc = toc;% in loop

if H.do_update(this_iter)
    H.tocs_idx = H.tocs_idx + 1;    
    tocs_idx = H.tocs_idx; 
    total_iters = H.total_iters;
    H.tocs(tocs_idx) = this_toc;
    timeElapsed = this_toc;
%     iter_left = total_iters - this_iter;
    iter_left = H.numel_toc - tocs_idx;
    timeLeft = nanmedian(diff(H.tocs))*iter_left;

    [timeElapsed,timeLeft] = sec2str(timeElapsed,timeLeft);
    wtbarMSG = sprintf(H.waitbar_message,this_iter,total_iters,timeElapsed,timeLeft);
    perc = this_iter*H.inv_total_iters;
    waitbar(perc,H.waitbarHandle,wtbarMSG);
    
end
end

