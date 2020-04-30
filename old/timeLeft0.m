% tic; H = timeLeft0(total_iters,functionNm)
% for i = 1:total_iters
%     [H] = timeLeft1(toc,i,H)
% end
% delete(H.waitbarHandle);
function H = timeLeft0(total_iters,functionNm,varargin)
if nargin>2
    updateevery = varargin{1};
else
    updateevery = 100;
end



H = struct();
H.waitbarHandle = waitbar(0,'Initializing...');

H.tocs_idx = 0;
do_update = false(1,total_iters);

if total_iters>updateevery
    inters = ceil(total_iters/updateevery);
else
    inters = 1;
end
do_update(1:inters:end) = true;
do_update(end) =  true;

H.numel_toc = sum(do_update);
H.tocs = NaN(1,H.numel_toc);
H.do_update = do_update;
H.inv_total_iters = total_iters^(-1);
H.total_iters = total_iters;
H.waitbar_message = ['[',functionNm,'] (%d/%d)\n','TimeElapse=%s, TimeLeft=%s.'];

end