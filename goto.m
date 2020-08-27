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
                'manuscript GJI 2020','gji2020_manuscript','matlab_script');
            cd(dir_x);
        end
        
        function dir_return = gji20rup()
            root0 = RootFolder;
            dir_x = fullfile(root0,'0MyResearch','(0)submission',...
                'manuscript GJI 2020','gji2020_manuscript','matlab_script','RuptureStatistics');
            dir_data = fullfile(root0,'1Programming','DATA','TEX_fit_SDE_gen_DATA','GJI20');
            if nargin>0
                % don't cd
                dir_return = dir_x;
                fprintf('No cd, and return the directory of scripts. \n');
            else
                cd(dir_x);
                dir_return = dir_data;
                fprintf('Current working directory switched to %s\n',dir_x);
                fprintf('Return the directory for data in workspace: \n');
            end
        end
        
        function dir_x = toolbox(varargin)
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','toolbox');
            if nargin>0
                % don't cd
            else
                cd(dir_x);
            end
        end
        
        function dir_x = cwb()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','CWB_precursor');
            cd(dir_x);
        end
        
        function dir_x = MagTIP2020()
            root0 = RootFolder;
            dir_x = fullfile(root0,'1Programming','MATLAB','CWB_precursor',...
                'MagTIP-2020','script');
            cd(dir_x);
        end
    end
    

end

