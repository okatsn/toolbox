FigType = 'Zechar Fig. 3a';
% FigType = 'Zechar Fig. 3b';
plotAB = false;
switch FigType
    case 'Zechar Fig. 3a'
        alphaList = [0.01,0.05,0.25,0.5];
        NList = 15;
        plotAB = true;
    case 'Zechar Fig. 3b'
        alphaList = 0.05;
        NList = [5,15,50,100]; 
    otherwise
        error("'FigType' can be either 'Zechar Fig. 3a' or 'Zechar Fig. 3b'");
end

rangeN = 1:length(NList);
rangea = 1:length(alphaList);
lgd = {};

figure;
for ia = rangea
    alpha = alphaList(ia);
for iN = rangeN
    N = NList(iN);
    [molt_cb,moln_cb] = Molchan_CB(N,alpha);


    plot(molt_cb,moln_cb);
    hold on
    
    lgdtxt = sprintf('N=%d; \\alpha=%s',N,num2str(alpha));
    lgd = [lgd,{lgdtxt}];
end
end

ylim([0,1]);
xlim([0,1]);
xlabel('$\tau$ (fraction of alarmed cells)','Interpreter','latex');
ylabel('$\nu$ (fraction of missing earthqakes)','Interpreter','latex');
axis square
legend(lgd);
if plotAB
% plot point A
hitnumA = 8;
XA = 0.19;
YA = (N-hitnumA)/N; % miss rate (\nu) in Zechar 2008
plot(XA,YA,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
text(XA+0.02,YA,sprintf('A, %d hits',hitnumA));
% lgdtxt = sprintf('%d hits.',hitnumA);
% lgd = [lgd,{lgdtxt}];

% plot point B
hitnumB = 11;
XA = 0.59;
YA = (N-hitnumB)/N; % miss rate (\nu) in Zechar 2008
plot(XA,YA,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
text(XA+0.02,YA,sprintf('B, %d hits',hitnumB));
% lgdtxt = sprintf('%d hits.',hitnumB);
% lgd = [lgd,{lgdtxt}];

% delete extra legend
ax = gca;
ax.Legend.String(end-1:end) = [];
grid on
end



%% (Old)

% FigType = 'Zechar Fig. 3a';
% FigType = 'Zechar Fig. 3b';
plotAB = false;
switch FigType
    case 'Zechar Fig. 3a'
        alphaList = [0.01,0.05,0.25,0.5];
        NList = 15;
        plotAB = true;
    case 'Zechar Fig. 3b'
        alphaList = 0.05;
        NList = [5,15,50,100]; 
    otherwise
        error("'FigType' can be either 'Zechar Fig. 3a' or 'Zechar Fig. 3b'");
end





PA_tilde =  linspace(0,1,10000)';

molt = PA_tilde;
rangeN = 1:length(NList);
rangea = 1:length(alphaList);
lgd = {};

figure;
for ia = rangea
    alpha = alphaList(ia);
for iN = rangeN
    N = NList(iN);
    B = @(k) factorial(N)/(factorial(k)*factorial(N-k))*(molt.^k).*((1-molt).^(N-k));
    hList = 1:N;
    rangeh = 1:length(hList);
    molt_cb = NaN(size(rangeh));
    moln_cb = NaN(size(rangeh));
    cbi= 1;
    for ih = rangeh
        h = hList(ih);
        P_h_or_more = zeros(size(molt));
        for k = h:N
            P_h_or_more = P_h_or_more + B(k);
        end
        [idx_min_molt,val_1] = nearest1d(P_h_or_more,alpha);
        molt_cb(cbi) = molt(idx_min_molt);
        moln_cb(cbi) = (N-h)/N; % miss rate (\nu) in Zechar 2008
        cbi = cbi+1; 
        if any(P_h_or_more>1.0001)
           error('P_h larger than zero.') 
        end

    end


    plot(molt_cb,moln_cb);
    hold on
    
    lgdtxt = sprintf('N=%d; \\alpha=%s',N,num2str(alpha));
    lgd = [lgd,{lgdtxt}];
end
end

ylim([0,1]);
xlim([0,1]);
xlabel('$\tau$ (fraction of alarmed cells)','Interpreter','latex');
ylabel('$\nu$ (fraction of missing earthqakes)','Interpreter','latex');
axis square
legend(lgd);
if plotAB
% plot point A
hitnumA = 8;
XA = 0.19;
YA = (N-hitnumA)/N; % miss rate (\nu) in Zechar 2008
plot(XA,YA,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
text(XA+0.02,YA,sprintf('A, %d hits',hitnumA));
% lgdtxt = sprintf('%d hits.',hitnumA);
% lgd = [lgd,{lgdtxt}];

% plot point B
hitnumB = 11;
XA = 0.59;
YA = (N-hitnumB)/N; % miss rate (\nu) in Zechar 2008
plot(XA,YA,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
text(XA+0.02,YA,sprintf('B, %d hits',hitnumB));
% lgdtxt = sprintf('%d hits.',hitnumB);
% lgd = [lgd,{lgdtxt}];

% delete extra legend
ax = gca;
ax.Legend.String(end-1:end) = [];
grid on
end



