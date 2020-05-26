function FIM = FisherInformation(pdfx,x)
% use other function to calculate the probability density function, e.g. [pdfx,x]= ksdensity(inputDataCollection); 



% xiMw = 1:length(pdfx); % index for x and pdfx
% 
% if length(pdfx) ~= length(xiMw)
%     error('x and pdfx should have the same length.');    
% end
maxiter = 15;
for i = 1:maxiter
    dx = gradient(x);
    dfdx = gradient(pdfx)./dx; %gradient(pdfx,dx(1)); 

    not_ok_id = dx > dfdx;
    cannot_pass = any(not_ok_id);
    if cannot_pass
        xq = x(1:end-1) + 0.5*diff(x);
        xq = sort([x(:);xq(:)]);
        vq2 = interp1(x,pdfx,xq,'spline');
        x = xq;
        pdfx = vq2;
    else 
        break
%         plot(x,pdfx,'o',xq,vq2,':.');
    end

end
if i == maxiter
    dx = gradient(x);
    dfdx = gradient(pdfx)./dx; %gradient(pdfx,dx(1)); 
    warning('[FisherInformation] Maximum iteration reached; output pdf might not be good enough.');
end
% x(end) = [];
% pdfx(end) = []; %to make the elements of dx, dfdx the same with x and pdfx

FIMPre = dfdx.^2.*dx./pdfx;
FIM = sum(FIMPre);

if FIM>1e18
    disp(''); 
end

shouldbe1 = sum(pdfx.*dx);
if shouldbe1 > 1.01 || shouldbe1<0.99
    
    warning('[FisherInformation] Sum of pdf deviates from 1 (int(pdfx) =%.5f)',shouldbe1);
end
% id2small = pdfx < dx;
% pdfx(id2small) = dx(id2small);

% Please refer to Eq.3 in *Analysis of dynamics in magnetotelluric data by
% using the Fisher¡VShannon method* by Luciano Telesca, Michele Lovallo,
% Han-Lun Hsu, Chien-Chih Chen (2011)

% To impove, refer to 
% https://stackoverflow.com/questions/29478838/whats-the-best-way-to-calculate-a-numerical-derivative-in-matlab
% https://www.mathworks.com/matlabcentral/answers/281526-accurate-numerical-differentiation-for-large-time-series-data
% https://www.mathworks.com/matlabcentral/fileexchange/16997-movingslope
end