classdef goto
% This class is dependent of quickcd, and gives a quick switch between
% shortcuts.
% This is not the goto in the conventional sense.
    
%     properties (Constant, Access = private)
%         progfoldername = '1Programming';
%     end
    
%     properties (Dependent)
% %         sde
% %         matlab_project
%     end
    
    methods (Static)       
        function dir_x = matlab_projects()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB');
            cd(dir_x);
        end
        
        function dir_x = sde()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','TEX_fit_SDE_gen');
            cd(dir_x);
        end
        
        function dir_x = submission()
            root0 = RootFolder;
            dir_x = fullfile(root0,'0MyResearch','(0)submission');
            cd(dir_x);
        end
        
        function dir_x = gji20()
            root0 = RootFolder;
            dir_x = fullfile(root0,'0MyResearch','(0)submission',...
                'manuscript GJI 2020','matlab_script');
            cd(dir_x);
        end
        
        function dir_x = gji20rup()
            root0 = RootFolder;
            dir_x = fullfile(root0,'0MyResearch','(0)submission',...
                'manuscript GJI 2020','matlab_script','RuptureStatistics');
            cd(dir_x);
        end
        
        function dir_x = toolbox()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','toolbox');
            cd(dir_x);
        end
        
        function dir_x = cwb()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','CWB_precursor');
            cd(dir_x);
        end
        
    end
    

end
