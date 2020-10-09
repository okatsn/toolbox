function r = reduce_(f,varargin)
% example reduce(@max,2,3,4,5)
% equivalent to mx = max([2, max([3, max([4, 5])])]);
% https://stackoverflow.com/questions/29875376/matlab-equivalent-of-pythons-reduce-function
while length(varargin)>1
    varargin{end-1}=f(varargin{end-1},varargin{end});
    varargin(end)=[];
end
r=varargin{1};
end
