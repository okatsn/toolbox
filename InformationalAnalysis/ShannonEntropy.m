function Hx = ShannonEntropy(pdfx,x)
% use other function to calculate the probability density function, e.g. [pdfx,x]= ksdensity(inputDataCollection); 




% xiMw = 1:length(pdfx); % index for x and pdfx
% 
% if length(pdfx) ~= length(xiMw)
%     error('x and pdfx should have the same length.');    
% end

dx = gradient(x);
% x(end) = [];
% pdfx(end) = []; %%to make the elements of dx, dfdx the same with x and pdfx
% HxPre = pdfx .* log10(pdfx) .* dx;
HxPre = pdfx .* log(pdfx) .* dx;
Hx = -sum(HxPre);

% Please refer to Eq.4 in *Analysis of dynamics in magnetotelluric data by
% using the Fisher¡VShannon method* by Luciano Telesca, Michele Lovallo,
% Han-Lun Hsu, Chien-Chih Chen (2011)


end