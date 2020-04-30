function [pwd1] = back2(pwd1,fullfoldername,varargin)
% 1. if input ischar: go back to parent folder (foldername) according to pwd (current directory)
% 2. if input N is double: go back to N level.
% 3. back_to(pwd,'1MyResearch','MATLAB','add-on','and_so_on') will go back '1MyResearch', and then
% proceed to 'MATLAB/add-on/and_so_on'. i.e. ../1MyResearch/MATLAB/add-on/and_so_on
% pwd1 = [pwd '\MATLAB\1235'];

if isa(fullfoldername,'double')
    for i = 1:fullfoldername
        pwd1 = fileparts(pwd1);
    end
%     return
end



if ischar(fullfoldername)
    A = regexp(pwd1,fullfoldername);
    if numel(A)>1
        warning('Two or more identical folder names in this path. Nearest one is chosen.')
    end
    del_from = A(end) + numel(fullfoldername);
    pwd1(del_from:end) = [];
%     return
    
end

% assignin('base','varargin',varargin);

if nargin > 2
    NoVar = length(varargin);
    for i = 1:NoVar
        pwd1= fullfile(pwd1,varargin{i});
    end  
end
validpath(pwd1,'mkdir');

end

