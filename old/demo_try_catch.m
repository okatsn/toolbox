%% Try and Error
extension = regexp('foldername','\.\w+','match');
    try
    B = erase('foldername',extension{end});
    catch ME
        switch ME.identifier
            case 'MATLAB:badsubscript'
                disp('target has no extension. \n')
            otherwise
                assignin('base','ME',ME); % to see what is the expected error.
                timestamp = datestr(now,'yyyymmdd,hh:MM');
                errorinfo = sprintf('[%s] at permPS.m. (%s)',ME.identifier,timestamp);
                dlmwrite('error_log.txt',errorinfo,'delimiter','','-append');              
                
%                 rethrow(ME);
        end 
    end
    
%% raise error

try 
    
    errorStruct.identifier = 'Custom:Error';
    errorStruct.message = 'images may overlap';
    error(errorStruct)
catch ME
    if strcmp(ME.identifier,errorStruct.identifier)
        disp(ME.message)
    else 
        rethrow(ME);
    end
    
    
end
    
    