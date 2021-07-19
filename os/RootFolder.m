function [varargout] = RootFolder(varargin)
% [root0,pf_iters,nickname] = RootFolder
% [root0,pf_iters,nickname] = RootFolder(0) % don't print information.
% root0: the anchor point for relative paths/directories for different devices.
% pf_iters: number of maximum thread for parfor
% nickname: nick name for the device
do_print = true;
if nargin > 0
    do_print = varargin{end};
end

pf_iters = feature('numcores'); % number of maximum threads for parfor
linux_ncu = 'Linux_NCU_CGRG';

computer_name = getenv('COMPUTERNAME');
if isempty(computer_name) && pf_iters ==16
    computer_name = linux_ncu;
end


switch computer_name
    case 'DESKTOP-8Q9V6U2' 
        root0 = 'C:\Google THW';
        nickname = 'PC in Lab (old)';
    case 'DESKTOP-800FKD5'
        root0 = 'D:\GoogleDrive';
        nickname = 'PC in Lab';
    case 'LAPTOP-H2N83MUU'
        root0 = 'D:\GoogleDrive';
        nickname = 'laptop ASUS TUF';        
    case linux_ncu
        root0 = '/data-hdd/shared/TsungHsi';
%         pf_iters = 12;
%         warning('numcore is 16 but actually only 12 cores can be used in parfor.');
        nickname = 'Linux in NCU';
    otherwise
        error('Error in specifying root folder. See RootFolder');
end
if do_print
    fprintf('%d cores available. This is %s\n',pf_iters,nickname);
end
varargout{1} = root0;
if nargout>1
    varargout{2} = pf_iters;
    if nargout >2
        varargout{3} = nickname;
    end
end

end

