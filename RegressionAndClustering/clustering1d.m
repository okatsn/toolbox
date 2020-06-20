function [clusters, cluster_of_indices_for_X] = clustering1d(X, varargin)
% This function separate 1d data X into clusters/groups using [pdfx,x] =  ksdensity(...).
% The split lines are the local minima of pdfx.
% Note that if pdfx is bad, the result will be awful.

% As suggested,
% (https://stats.stackexchange.com/questions/40454/determine-different-clusters-of-1d-data-from-database)
% it is not efficient to use k-means to separate 1d data into groups.
% You can also use Jenks Natural Breaks for 1d clustering problem.
% https://www.mathworks.com/matlabcentral/fileexchange/72677-clustering-via-jenks-natural-breaks
% https://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization

error('This function is under construction...');

if nargin>1 && ~isa(varargin{1},'char') % either nbins or edges assigned
    secondarg = varargin{1};
    varargin(1) = [];
else
    secondarg = [];
end

[pdfx,xp] = ksdensity(X);


end

