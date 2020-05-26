function [varargout] = infoAnalysis(inputTs,informationalType,varargin)
% Hx = infoAnalysis(inputY,'Shannon','DisplayPDF',10); 
% % calculate Shannon entropy and display the progress at update rate every 0.1*MovingWindowLength
%
% [Hx,FIM] = infoAnalysis(inputY,{'Shannon','Fisher'},'DisplayPDF',10); 
% %calculate Shannon entropy and Fisher Information at once.
idx.FIM = 1; % 1st:  Fisher information
idx.Nx = 2;  % 2nd: Shannon Entropy

validInt = @(x) isnumeric(x) && floor(x)==x;
validIntorLogic = @(x)  islogical(x)|| isnumeric(x) && floor(x)==x;
p = inputParser;
addParameter(p,'WindowLength',0,validInt);
addParameter(p,'DisplayPDF',0,validIntorLogic); % e.g. 'DisplayPDF', 2 play the animation ~2 times faster.

parse(p,varargin{:});
WLength = p.Results.WindowLength;
displaypdf = p.Results.DisplayPDF;

TsLength = length(inputTs);

NoFunc = length(fieldnames(idx)); % number of functions
infoFuncArray = cell(NoFunc,1);

infoFuncArray{idx.FIM} = @(pdfx,x) FisherInformation(pdfx,x);    %  @(x) ecmnfish(x);
infoFuncArray{idx.Nx} = @(pdfx,x) ShannonEntropy(pdfx,x);      % @(x)Entropy_by_david(x); @(x) wentropy(x,'shannon');

% do_calculate = false(1,NoFunc);
switch class(informationalType)
    case 'char'
        informationalType = {informationalType};
    case 'cell'
        
    otherwise
        error('Wrong function type. It must be char or cell array containing char');
    
end
NoTask = length(informationalType);
calcRng = []; % index for infoFuncArray

for i = 1:NoTask
    switch informationalType{i}
        case {'Fisher','FisherInformation','FIM'}
            calcRng = [calcRng,idx.FIM]; 
        case {'Shannon','ShannonEntropy','ShannonEntropyPower'}
            calcRng = [calcRng,idx.Nx];
            
        otherwise
            error('Unknown function name.');
    end
end


if isequal(WLength,0)
    WLength = round(TsLength*0.1);
else
    
end

if WLength>TsLength
    error('window length should not be larger than the whole time series.');
end

% outputCell = cell(NoTask,1);
OutputInfo = NaN(TsLength,NoFunc);

% output timeseries starts from the end of the first moving time window.
% e.g. if Window length = 500, the 501th is the first calculated shannon entropy for inputTs(1:500). 

Rangei = WLength:TsLength;

displaypdf1 = false;
if ~isequal(displaypdf,0)
    displaypdf1 = true; % faster in the following for loop
    figure;
    sb1 = subplot(3,1,1);
    title('input time series');
    plot(inputTs);
    hold on
    xstart = 0;
    ystart = sb1.YLim(1);
    xlength = WLength;
    ylength = diff(sb1.YLim);
    reccolor = [0.3010, 0.7450, 0.9330]; % cyan
    rc = rectangle('Position',[xstart,ystart,xlength,ylength],'EdgeColor',reccolor,'FaceColor',[reccolor, 0.4]); % 'FaceColor', [R,G,B,Alpha]
    subplot(3,1,2)
    title('probability density function in the moving window');
    
    updateEvery = ceil(0.01*displaypdf*WLength); % update the preview every X steps;
    updateInd = false(length(Rangei),1);
    updateInd(1:updateEvery:end) = true;
    
    set(gcf,'Position',[100,100,650,900]);
    xlim1 = sb1.XLim;
    output_std_Ts = NaN(TsLength,1);
    
end

for i = Rangei 
    ind0 = i-WLength+1;
    xi = inputTs(ind0:i);
    [pdfx,x]= ksdensity(xi,'NumPoints',100); % NumPoints of 100 looks similar to that of 10000
    
      
    for j = calcRng
%         if do_calculate(j)
            infoFunc = infoFuncArray{j};
            OutputInfo(i,j) = infoFunc(pdfx,x);
%         end
    end
%     ShannonEntropyHx(i) = wentropy(xi,'shannon');
    if displaypdf1 && updateInd(ind0)
        xstart = ind0;
        rc.Position = [xstart,ystart,xlength,ylength];
        sb2 = subplot(3,1,2);
        
        plot(x,pdfx);
        stdxi = std(xi); output_std_Ts(i) = stdxi;
        legend(sprintf('pdf(x); std=%.3f',stdxi),'Location','northeast');
        
        sb3 = subplot(3,1,3);
        yyaxis left
        plot(OutputInfo(:,idx.FIM));
        ylabel('Fisher Information');
        yyaxis right
        plot(OutputInfo(:,idx.Nx));
        ylabel('Shannon Entropy');
        sb3.XLim = xlim1;
        drawnow
    end
end

varargout0 = mat2cell(OutputInfo,[TsLength],ones(1,NoFunc));

varargout = varargout0(calcRng); 

if NoTask>1
    disp("[infoAnalysis] Output arguments are in the same order of 'informationalType'.");
end

if displaypdf1 
    assignin('base','std_of_moving_window',output_std_Ts);
end

% if doPower
%     OutputInfo = ShannonEntropyPower(OutputInfo);
%     dispmsg = 'Shannon entropy power (Nx)';
% end
% disp(dispmsg);

end





function  H = Entropy_by_david(objectSet,varargin)
%ENTROPY Compute the Shannon entropy of a set of variables.
%   ENTROPY(X,P) returns the (joint) entropy for the joint distribution 
%   corresponding to object matrix X and probability vector P.  Each row of
%   MxN matrix X is an N-dimensional object, and P is a length-M vector 
%   containing the corresponding probabilities.  Thus, the probability of 
%   object X(i,:) is P(i).  
%
%   ENTROPY(X), with no probability vector specified, will assume a uniform
%   distribution across the objects in X.
%   
%   If X contains duplicate rows, these are assumed to be occurrences of the 
%   same object, and the corresponding probabilities are added.  (This is 
%   actually the only reason that object matrix X is needed -- to detect and 
%   merge repeated objects.  Of course, the entropy itself only depends on 
%   the probability vector P.)  Matrix X need NOT be an exhaustive list of 
%   all *possible* objects in the universe; objects that do not appear in X
%   are simply assumed to have zero probability. 
%
%   The elements of probability vector P must sum to 1 +/- .00001.
%
%   For further information about entropy in information theory, see
%   <a href="matlab:web('http://en.wikipedia.org/wiki/Information_entropy','-browser')">Information entropy</a>. Wikipedia, The Free Encyclopedia. 
%  
%   See also: MUTUALINFO

%% Error checking %%
if size(objectSet,1) == 1,
    objectSet = objectSet';
    %warning('Object set row vector is being transposed to a column vector.')
end
if ~isempty(varargin),
    probSet = varargin{1};
else
    probSet = repmat(1/size(objectSet,1),size(objectSet,1),1);
end
if ~isequal(size(objectSet,1),length(probSet)),    
    error('Object set must have an object for each probability.')
end
% Check probabilities sum to 1:
if abs(sum(probSet) - 1) > .00001,
    error('Probablities don''t sum to 1.')
end

%% Merge duplicate objects/probabilities %%
% We do not use objectSet in the calculations, but just need to deal with 
% duplicated objects (add probabilities together).
[minimalObjSet I equivClass] = unique(objectSet,'rows');
if ~isequal(size(minimalObjSet,1),size(objectSet,1)),    
    probSetReduced = zeros(size(minimalObjSet,1),1);
    for i = 1:length(probSetReduced),     
        probSetReduced(i) = sum(probSet(equivClass==i));
    end   
    probSet = probSetReduced;
end

%% Remove any zero probabilities %%
zeroProbs = find(probSet < eps);
if ~isempty(zeroProbs),
    probSet(zeroProbs) = [];
    %disp('Removed zero or negative probabilities.')
end

%% Compute the entropy
H = -sum(probSet .* log2(probSet));  % original 
% H = -sum(probSet .* log10(probSet));  % ?

% Copyright (c) 2016, David Fass
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

end
