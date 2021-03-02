function dispx(Strs,varargin)
% display multiple lines the same time
% dispx({Str1,Str2,...},'Indentation',[1]) % do indent every row 
                                           % with indent size 1 whitespaces.
% dispx({Str1,Str2,...},'Indentation',[2,4]) % do indent every 2 row
                                           % with indent size 4 whitespaces.
p = inputParser;
addParameter(p,'Indentation',[0,0]); % [m, n] for do indent every next m row
                                   % with number of indent n white space.
addParameter(p,'BlankLine',0); % m for one blank line every next m row

parse(p,varargin{:});
Indent = p.Results.Indentation;
blankLine = p.Results.BlankLine;
nstr = length(Strs);
if isequal(Indent(1), 0)
    do_indent = false;
else
    do_indent = true;
    numIndent = Indent(end);
    A = strings(1,numIndent);
    A(:) = " "; 
    whiteSpaces = horzcat(A{:});
    do_indent_at = Indent(1):Indent(1):nstr;
end

if isequal(blankLine,0)
    do_blankLine = false;
else
    do_blankLine = true;
    do_blackLine_at = blankLine:blankLine:nstr;
end

for i = 1:nstr
    if do_indent && ismember(i,do_indent_at)
        str2disp = [whiteSpaces,Strs{i}]; % indentation
    else
        str2disp = Strs{i}; % no indent
    end
    disp(str2disp);
    if do_blankLine && ismember(i,do_blackLine_at)
        disp('    ');
    end
end


end