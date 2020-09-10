function parSave(filename,x,varargin)
% the save function that is workable in parfor.
    save(filename,'x',varargin{:});
end