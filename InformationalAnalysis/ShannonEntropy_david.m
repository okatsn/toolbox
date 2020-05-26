function  H = ShannonEntropy_david(objectSet,varargin)
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
H = -sum(probSet .* log2(probSet));   


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

