function [root0,pf_iters,varargout] = RootFolder
pf_iters = feature('numcores'); 
linux_ncu = 'Linux_NCU_CGRG';

computer_name = getenv('COMPUTERNAME');
if isempty(computer_name) && pf_iters ==16
    computer_name = linux_ncu;
end


switch computer_name
    case 'DESKTOP-8Q9V6U2' 
        root0 = 'C:\Google THW';
        nickname = 'PC in Lab';
    case 'LAPTOP-H2N83MUU'
        root0 = 'D:\GoogleDrive';
        nickname = 'laptop ASUS TUF';        
    case linux_ncu
        root0 = '/data-hdd/shared/TsungHsi';
        pf_iters = 12;
        warning('numcore is 16 but actually only 12 cores can be used in parfor.');
        nickname = 'Linux in NCU';
    otherwise
        error('Error in specifying root folder. See RootFolder');
end

fprintf('%d cores available. This is %s',pf_iters,nickname);
if nargout >2
    varargout{1} = nickname;
end
end

