% tic; H = timeLeft0(total_iters,functionNm)
% for i = 1:total_iters
%     [H] = timeLeft1(toc,i,H)
% end
% delete(H.waitbarHandle);
% 
% OR
% 
% tic; H1 = timeLeft0(length(range_k),'Iter over range_k',[0,2]);
% 
% for k = range_k
%     [H1] = timeLeft1(toc,k,H1);
%     
%     tic2 = toc; H2 = timeLeft0(length(range_i),'Iter over range_i',[0,1]);
%     for i = range_i
%         toc2 = toc - tic2; [H2] = timeLeft1(toc2,i,H2);
%     end
%     delete(H2.waitbarHandle);
% end
% delete(H1.waitbarHandle);
%
%
% OR 
% tic; H = timeLeft0(total_iters,'titlename',10000); timeleftcounts = 1;
% for ..
%     for ...
%         [H] = timeLeft1(toc,timeleftcounts,H); timeleftcounts = timeleftcounts +1;            
%     end
% end
% delete(H.waitbarHandle);

function H = timeLeft0(total_iters,functionNm,varargin)
pos_H = [441, 292, 300, 63];
updateevery = 100;
if nargin>2
    if nargin == 3
        switch length(varargin{1})
            case 1
                updateevery = varargin{1};
            case 2
                pos_xy = varargin{1}.*[pos_H(3:4)+[0,15]];
                pos_shift = [pos_xy,0,0];
                pos_H = pos_H + pos_shift;
            otherwise
                warning('Error in input argument 3 or 4. Use default settings.');
        end
    elseif nargin == 4
        updateevery = varargin{1};
        pos_xy = varargin{2}.*[pos_H(3:4)];
        pos_shift = [pos_xy,0,0];
        pos_H = pos_H + pos_shift;
    end
end
H = struct();
H.waitbarHandle = waitbar(0,'Initializing...');
H.waitbarHandle.Position = pos_H;
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