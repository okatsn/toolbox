function parSave(filename,S_parsaved,varargin)
% the save function that is workable in parfor.
    save(filename,'S_parsaved',varargin{:});
end