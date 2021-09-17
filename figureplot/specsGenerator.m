function [varargout] = specsGenerator(varargin)
% generate specifications.
% for example, mklist = specsGenerator('Marker',3);
% where mklist = {'o','+','*','.','x'};
% E.g. [linestyles,markers] = specsGenerator('LineStyle',10,'Marker',3);
numvarin = nargin;
if rem(numvarin,2) ~= 0
    error("Input arguments must be name-value pairs. E.g. 'Marker',3, 'LineStyle',2,... ");
end

numtypes = numvarin/2;
varargout = cell(1,numtypes);
all_markers = {'o';'s';'d';'^';'v';'>';'<';'p';'h';'+';'*';'.';'x'};
all_linestyles = {'-'; '--'; ':'; '-.'};

for i = 1:numtypes
    name_i = varargin{2*i-1};
    value_i = varargin{2*i};
    
    switch name_i
        case 'Marker'
            specs = all_markers;
            while value_i > length(specs)
                specs = [specs;all_markers];
            end
            varargout{i} = specs(1:value_i);
        case 'LineStyle'
            specs = all_linestyles;
            while value_i > length(specs)
                specs = [specs;all_linestyles];
            end
            varargout{i} = specs(1:value_i);
        otherwise
            error("Invalid name '%s'",name_i);
    end
    
    
end


end

