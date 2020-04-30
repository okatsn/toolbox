function [outputArg1] = bkvalidpath(varargin)
% input: a string such as pwd or 'C:\Google THW\1MyResearch\MATLAB\123'.
% output: (true or false) is the string a valid path or not. If a valid
% path but not exist, the folder will be created.
% e.g. trueorfalse = validpath('C:\Google THW\prob1')
% e.g. validpath('C:\Google THW\prob1','rmdir') % remove the created direction
% NOTE: only1field.m depends on validpath.m
firstArg = varargin{1};
mkdirmsg = 'folder not exist. Folder created.';
if isfolder(firstArg)
    % this is a valid folderpath
    outputArg1 = true;
else
    if isfile(firstArg)
        outputArg1 = true;
    else
        try
            mkdir(firstArg);
            disp('Path does not exist. Folder created.');
            outputArg1 = true; % if no error, then it is a valid path.
            if nargin >1
                if any(strcmp(varargin,'rmdir'))
                    rmdir(firstArg);
                    disp('Folder removed.');
                    return                   
                end
            end
            warning(mkdirmsg);
        catch ME
                if strcmp(ME.identifier,'MATLAB:MKDIR:OSError')
                    warning('This is not a valid path.');
                    outputArg1 = false;
                    return
                else
                    warning('Unknown error. Noted that folder may be created.')
                    rethrow(ME);
                end


        end % try mkdir
    end % isfile(p)
end %isfolder(p)
        

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


