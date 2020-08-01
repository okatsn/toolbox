function [varargout] = prelocatevars(inputvar)
% prelocate same variables
% e.g. 
% [var1,var2,var3,...] = prelocatevars(NaN(3,1))
% is equivalent to 
%     var1 = NaN(3,1);
%     var2 = NaN(3,1);
%     var3 = NaN(3,1);
%     ...
varargout = cell(1,nargout);
varargout(:) = {inputvar};
end

