function [range1] = julialikerange(id0,id1,varargin)
% This is a julia-like range function. 
% 1. julialikerange(7,10,1) gives [7,8,9,10], the same as 
% Base.range(7,10,step=1) in julia.
% 2. julialikerange([1,9,14],[5,10,19])
%     ans =
%          1, 2, 3, 4, 5, 9, 10, 14, 15, 16, 17, 18, 19
julialikerange0 = @(id0,id1,step) id0:step:id1;
if nargin>2 % 3rd argument
    step = varargin{1};
else 
    step = 1;
end

if isscalar(id0)
    range1 = julialikerange0(id0,id1,step);    
else
    ranges_cell = arrayfun(@(id0,id1) julialikerange0(id0,id1,step), id0(:),id1(:),'UniformOutput',false);
    range1 = cat(2,ranges_cell{:});
    
end





end

