function [molt_cb,moln_cb] = Molchan_CB(N,alpha,varargin)
% confidence bounds in molchan diagram
% N: total number of events

PA_tilde =  linspace(0,1,1000)';
molt = PA_tilde; % the probability-weighted area of alarmed region, equal to P(A).
B = @(k) factorial(N)/(factorial(k)*factorial(N-k))*(molt.^k).*((1-molt).^(N-k));

hList = 1:N; % h: number of event that hit the alarmed area.
rangeh = 1:length(hList);
molt_cb = NaN(size(rangeh));
moln_cb = NaN(size(rangeh));
cbi= 1;
for ih = rangeh
    h = hList(ih);
    P_h_or_more = zeros(size(molt));
    for k = h:N % \sum_{n=h}^{N}B(n|N,molt). See Eq. 3 in Zechar 2008.
        P_h_or_more = P_h_or_more + B(k);
    end
    % finding the minimum value of \tau (i.e. molt) that solves the
    % equality in Eq. 3 (Zechar 2008) for each discrete \nu (i.e. moln).
    [idx_min_molt,val_1] = nearest1d(P_h_or_more,alpha);
    molt_cb(cbi) = molt(idx_min_molt);
    moln_cb(cbi) = (N-h)/N; % miss rate (\nu) in Zechar 2008
    cbi = cbi+1; 
    if any(P_h_or_more>1.0001)
       error('P_h should not larger than one.') 
    end

end


% plot(molt_cb,moln_cb);
% hold on
% 
% lgdtxt = sprintf('N=%d; \\alpha=%s',N,num2str(alpha));



end

