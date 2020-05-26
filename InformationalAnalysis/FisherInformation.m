function FIM = FisherInformation(pdfx,x)
% Instruction:
%     - Use an external function to calculate the probability density function 
%     - e.g. [pdfx,x]= ksdensity(inputDataCollection); 
%     
% Warning:
%     - This numerical of FIM would extremely deviate from analytical solution,
%       if pdfx contains a very small value.
%     - Please refer to this paper to fix this issue.
%         - (https://royalsocietypublishing.org/doi/full/10.1098/rsos.160582?fbclid=IwAR0Zq0QNRkuB-8fqRCuoPDdP3X0sX7JAuetYlz-ix8MBtmiAb3TjN7AjWN4)
% Hsi, 2020-05-26


% xiMw = 1:length(pdfx); % index for x and pdfx
% 
% if length(pdfx) ~= length(xiMw)
%     error('x and pdfx should have the same length.');    
% end

dx = gradient(x);

dfdx = gradient(pdfx)./dx; %gradient(pdfx,dx(1)); 

% x(end) = [];
% pdfx(end) = []; %to make the elements of dx, dfdx the same with x and pdfx

FIMPre = dfdx.^2.*dx./pdfx;
FIM = sum(FIMPre);

if FIM>10^15
    disp('set the debug point here.')
end

if any(pdfx<0)
    disp('set the debug point here.')
end

% Please refer to Eq.3 in *Analysis of dynamics in magnetotelluric data by
% using the Fisher¡VShannon method* by Luciano Telesca, Michele Lovallo,
% Han-Lun Hsu, Chien-Chih Chen (2011)

% To impove, refer to 
% https://stackoverflow.com/questions/29478838/whats-the-best-way-to-calculate-a-numerical-derivative-in-matlab
% https://www.mathworks.com/matlabcentral/answers/281526-accurate-numerical-differentiation-for-large-time-series-data
% https://www.mathworks.com/matlabcentral/fileexchange/16997-movingslope
end