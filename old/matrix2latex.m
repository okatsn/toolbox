function matrix2latex(matrix, filename, varargin)

% function: matrix2latex(...)
% Author:   M. Koehler
% Contact:  koehler@in.tum.de
% Version:  1.1
% Date:     May 09, 2004

% This software is published under the GNU GPL, by the free software
% foundation. For further reading see: http://www.gnu.org/licenses/licenses.html#GPL

% Usage:
% matrix2late(matrix, filename, varargs)
% where
%   - matrix is a 2 dimensional numerical or cell array
%   - filename is a valid filename, in which the resulting latex code will
%   be stored
%   - varargs is one ore more of the following (denominator, value) combinations
%      + 'rowLabels', array -> Can be used to label the rows of the
%      resulting latex table
%      + 'columnLabels', array -> Can be used to label the columns of the
%      resulting latex table
%      + 'alignment', 'value' -> Can be used to specify the alginment of
%      the table within the latex document. Valid arguments are: 'l', 'c',
%      and 'r' for left, center, and right, respectively
%      + 'format', 'value' -> Can be used to format the input data. 'value'
%      has to be a valid format string, similar to the ones used in
%      fprintf('format', value);
%      + 'size', 'value' -> One of latex' recognized font-sizes, e.g. tiny,
%      HUGE, Large, large, LARGE, etc.
%
% Example input:
%   matrix = [1.5 1.764; 3.523 0.2];
%   rowLabels = {'row 1', 'row 2'};
%   columnLabels = {'col 1', 'col 2'};
%   matrix2latex(matrix, 'out.tex', 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-6.2f', 'size', 'tiny');
%
% The resulting latex file can be included into any latex document by:
% /input{out.tex}
%
% Enjoy life!!!
[Results2,varargin] = inputParser2(varargin,{'append','simplify'});

p = inputParser;
addParameter(p,'BracketType','pmatrix');
parse(p,varargin{:});
BracketType = p.Results.BracketType;
errorStruct.identifier = 'Custom:Error';

%     rowLabels = [];
%     colLabels = [];
%     alignment = 'l';
%     format = [];
%     textsize = [];
%     if (rem(nargin,2) == 1 || nargin < 2)
%         error('matrix2latex: ', 'Incorrect number of arguments to %s.', mfilename);
%     end

%     okargs = {'rowlabels','columnlabels', 'alignment', 'format', 'size'};
%     for j=1:2:(nargin-2)
%         pname = varargin{j};
%         pval = varargin{j+1};
%         k = strmatch(lower(pname), okargs);
%         if isempty(k)
%             error('matrix2latex: ', 'Unknown parameter name: %s.', pname);
%         elseif length(k)>1
%             error('matrix2latex: ', 'Ambiguous parameter name: %s.', pname);
%         else
%             switch(k)
%                 case 1  % rowlabels
%                     rowLabels = pval;
%                     if isnumeric(rowLabels)
%                         rowLabels = cellstr(num2str(rowLabels(:)));
%                     end
%                 case 2  % column labels
%                     colLabels = pval;
%                     if isnumeric(colLabels)
%                         colLabels = cellstr(num2str(colLabels(:)));
%                     end
%                 case 3  % alignment
%                     alignment = lower(pval);
%                     if alignment == 'right'
%                         alignment = 'r';
%                     end
%                     if alignment == 'left'
%                         alignment = 'l';
%                     end
%                     if alignment == 'center'
%                         alignment = 'c';
%                     end
%                     if alignment ~= 'l' && alignment ~= 'c' && alignment ~= 'r'
%                         alignment = 'l';
%                         warning('matrix2latex: ', 'Unkown alignment. (Set it to \''left\''.)');
%                     end
%                 case 4  % format
%                     format = lower(pval);
%                 case 5  % format
%                     textsize = pval;
%             end
%         end
%     end

if Results2.append
    fid = fopen(filename, 'a+');
else
    fid = fopen(filename, 'w');
end


    
if iscell(matrix)
    NoTerms = length(matrix);
    TermTypes = cell(1,NoTerms);
    for i = 1:NoTerms
        TermTypes{i} = class(matrix{i});       
    end  
else
    if isnumeric(matrix)
        TermTypes = {'double'};
        NoTerms = 1;
        matrix = {matrix};
    else
        errorStruct.message = 'Input matrices must satisty isnumeric==1 or a cell with numeric matrices';
        error(errorStruct);
    end
end

fprintf(fid, '$$\r\n'); % begin of latex math 

for i = 1:NoTerms
    matrix_i = matrix{i};
    if strcmp(TermTypes{i},'cell')
        convert2cell = false;
    else
        convert2cell = true;
    end
    
    switch TermTypes{i}
        case {'double','cell'}
            width = size(matrix_i, 2);
            height = size(matrix_i, 1);           
            if convert2cell
                matrix_i = num2cell(matrix_i);
                for h=1:height
                    for w=1:width
                            matrix_i{h, w} = num2str(matrix_i{h, w});
                    end
                end       
            end

                
            fprintf(fid, '\\begin{%s}',BracketType);
            rowRange = 1:height;
            colRange = 1:width;
            
            if Results2.simplify
                displayto = 4;
                
                if height > displayto+3
                    rowRange = [1:displayto, height-1,height];
                end
                
                if width > displayto+3
                    colRange = [1:displayto, width-1,width];
                end               
            end

            if Results2.simplify
                for h = rowRange
                    for w = colRange
                        if w==displayto
                            matrix_i{h, w} = '\cdots';
                        end
                        if h==displayto
                            matrix_i{h, w} = '\vdots';
                        end
                        if h==displayto&&w==displayto
                            matrix_i{h, w} = '\ddots';
                        end
                        
                        
                    end
                end
            end

            for h=rowRange
                for w=colRange
                    if w==width
                        fprintf(fid, '%s', matrix_i{h, w});
                    else
                        fprintf(fid, '%s&', matrix_i{h, w});
                    end
                end
                fprintf(fid, '\\\\\r\n');
            end
            fprintf(fid, '\\end{%s}\r\n',BracketType);
        case 'char'
            fprintf(fid, '%s\r\n',matrix_i);
    end
    

end

fprintf(fid, '$$\r\n');% end of latex math 



    fclose(fid);