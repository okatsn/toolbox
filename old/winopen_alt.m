function winopen_alt(inputArg1)
% The same as winopen but avoiding error on Linux
if ispc
    winopen(inputArg1);
    return
else
    warning('The winopen function is only available on MS windows. Error supressed and donothing.')
    return    
end


end

