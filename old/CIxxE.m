function [CIxxe] = CIxxE(datax,varargin)
% Compute the confidence interval according to empirical cdf of data.
% CIxxE(datax,quantileInterval,'DoSomething','Name1',value1)
% e.g. CIxxE(randn(1,100),[0.001,0.999],'SetYLim',1.2) % set YLim to the range of 1.2*CIxxe.
% This can be tested using:
% mu = 3; sigma = 5;
% xtest = mu+sigma*randn(10000,1);
% CI95qt = [0.025,0.975];
% CI95e = CIxxE(xtest,CI95qt)
% CI95n = norminv(CI95qt,mu,sigma)

p = inputParser;
addParameter(p,'SetYLim',0);
addParameter(p,'ConfidenceInterval',[0.025,0.975]);
parse(p,varargin{:});
r = p.Results;
CI95qt = r.ConfidenceInterval;%quantile for 95% confidence interval
SetYLim = r.SetYLim;

[A,B]=ecdf(datax);
[idxn,~] = nearest1d(A,CI95qt);
CIxxe = B(idxn)';

if SetYLim~=0
    diffCIxx = diff(CIxxe);
    set(gca,'YLim',CIxxe + [SetYLim*diffCIxx, SetYLim*diffCIxx]); % then reduce YLim to extended CI95
end

end

