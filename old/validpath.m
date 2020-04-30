function [outputArg1,varargout] = validpath(varargin)
% input: a string such as pwd or 'C:\Google THW\1MyResearch\MATLAB\123'.
% output: (true or false) is the string a valid path or not. If a valid
% path but not exist, the folder will be created.
% e.g. trueorfalse = validpath('C:\Google THW\prob1')
% NOTE: only1field.m depends on validpath.m
firstArg = varargin{1};
%%
pwd0 = pwd;
try
    cd(firstArg)
    outputArg1 = true;
%     disp('Folder exists.')
    cd(pwd0);
catch ME
    switch ME.identifier
        case 'MATLAB:string'
            outputArg1 = false;
            disp('validpath: input is not a string.')
        case 'MATLAB:cd:NonExistentFolder'
            if isfile(firstArg)
                outputArg1 = true;
%                 disp('this is a valid file (file exists)')
            else
                outputArg1 = false;
                disp('validpath: Name is not exist or not a directory')

                if nargin >1
                    if any(strcmp(varargin,'mkdir'))
                        try
                            mkdir(firstArg);
                        catch
                            warning("Error during mkdir('%s').",firstArg);
                            return
                        end
                        disp('Folder created:');
                        disp(firstArg);
                        return                   
                    end
                end

            end
        otherwise
            warning('validpath: unknown error.')
            rethrow(ME);
    end   
end
% if nargout>1
%     varargout{1} = fullfile(pwd0,);
% end
%%
% switch class(firstArg)
%     case {'char','string'}
% 
%         mkdirmsg = 'Path not exist. Folder created.';
%         if isfolder(firstArg)
%             % this is a valid folderpath
%             outputArg1 = true;
%         else
%             if isfile(firstArg)
%                 outputArg1 = true;
%             else
%                 try
%                     mkdir(firstArg);
%         %                     disp('Path does not exist. Folder created.');
%                     outputArg1 = true; % if no error, then it is a valid path.
%                     if nargin >1
%                         if any(strcmp(varargin,'rmdir'))
%                             rmdir(firstArg);
%                             disp('Folder removed.');
%                             return                   
%                         end
%                     end
%                     warning(mkdirmsg);
%                 catch ME
%                         if strcmp(ME.identifier,'MATLAB:MKDIR:OSError')
%                             warning('This is not a valid path.');
%                             outputArg1 = false;
%                             return
%                         else
%                             warning('Unknown error. Noted that folder may be created.')
%                             rethrow(ME);
%                         end
% 
% 
%                 end % try mkdir
%             end % isfile(p)
%         end %isfolder(p)
% 
%     otherwise
%         outputArg1 = false;
% %         warning('Input is not a string or a char array.')
% end
end


% expr4win =  '^(?:[a-zA-Z]\:(\\|\/)|file\:\/\/|\\\\|\.(\/|\\))([^\\\/\:\*\?\<\>\"\|]+(\\|\/){0,1})+$';
% % this takes too long in some cases. e.g.  regexp([pwd,'\/1'], expr4win, 'match')
% 
% expr2 = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$';
% % this doesn't work. e.g. regexp(pwd, expr2, 'match')
% 
% 
% if isempty(regexp(p, expr4win, 'once'))
%    outputArg1 = false;
% else
%     outputArg1 = true;
% end


