function [status] = checkpoint(varargin)
p = inputParser;
addParameter(p,'MissionComplete',false);
parse(p,varargin{:});

end

