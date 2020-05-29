function [cdfY,y] = cdfE(Y,varargin)
% Gives the empirical cumulative distribution function for Y
% By definition, cdfY is the probability that Y will take a value less than
% or equal to y; and ccdf Y is the probability that Y will take a value
% larger than y.
%
% How to use: 
%     [cdfY,y] = cdfE(Y,nbins); % nbins: number of bins (i.e. number of y points)
%     [cdfY,y] = cdfE(Y,y); % y is the mid-points of the edges of bins. % This is expected to be the fastest.
%                                                % Noted that the 'EdgeScale' has no effect on output results since y is specified.
%     [cdfY,y] = cdfE(Y);
%     [cdfY,y] = cdfE(...,'EdgeScale','log'); % output a log-spaced y.
%
%
% To get the CCDF of Y (complementary cumulative distribution function): 
%     ccdfY = 1- cdfY;
%
% Hsi, 2020-05-29

Y = Y(:);

if nargin>1 && ~isa(varargin{1},'char') % either nbins or edges assigned
    secondarg = varargin{1};
    varargin(1) = [];
else
    secondarg = [];
end
len2ndarg = length(secondarg);

p = inputParser;
addParameter(p,'EdgeScale','linear');
% addParameter(p,'Type','cdf');
parse(p,varargin{:});

% Type = p.Results.Type;

EdgeScale = p.Results.EdgeScale;
switch EdgeScale
    case 'linear'
        xxxspace = @(l,r,pt) linspace(l,r,pt);
        calcmidpoint = @(x) linearMidPoint(x);
    case 'log'
        negativeind = Y < 0;
        if any(negativeind)
            Y(negativeind) = [];
            warning("[cdfE] negative values is ignored because you set 'EdgeScale', 'log'.");
        end
        xxxspace = @(l,r,pt) logspace(log10(l),log10(r),pt);
        calcmidpoint = @(x) logMidPoint(x);
    otherwise
        error("'EdgeScale' has to be either 'linear' or 'log'. ");
end

invlenY = 1/length(Y);

if len2ndarg == 0 % cdfE(Y) or cdfE(Y,'EdgeScale','log');
    nbins = 100; % default.
    edge_left = min(Y);
    edge_right = max(Y);
    edges = xxxspace(edge_left,edge_right,nbins+1);
    y = calcmidpoint(edges); % length(y) should equals to nbins
elseif len2ndarg == 1 % cdfE(Y,nbins) or cdfE(Y,nbins,'EdgeScale','log');
    nbins = secondarg;
    edge_left = min(Y);
    edge_right = max(Y);
    edges = xxxspace(edge_left,edge_right,nbins+1);
    y = calcmidpoint(edges); % length(y) should equals to nbins
else % len2ndarg = 2 or larger. That is, cdfE(Y,y).
    y = secondarg;
    nbins = length(y);
end



cdfY = NaN(size(y));

% switch Type
%     case 'cdf'

%  cdf: probability that X will take a value less than or equal to x
        for i = 1:nbins
            B = Y <= y(i); % calculate cdf ()
            cdfY(i) = nnz(B)*invlenY; % number of non-zero elements/total number of elements
        end
%     case 'ccdf'
%         for i = 1:nbins
%             B = Y > y(i); % calculate ccdf
%             cdfY(i) = nnz(B)*invlenY; % number of non-zero elements/total number of elements
%         end
% end

end
